import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 'publication' ]
  static values = {
    url: String
  }


  connect() {
    this.queryPublications()
  }

  queryPublications() {
    const _this = this
    this.publicationTargets.forEach((pub) => {
      var id = pub.getAttribute('api-id')
      var idType = pub.getAttribute('api-id-type')
      if(id != null) {
        _this.openAlexInfo(id, idType) 
      }
    })
  }

  async openAlexInfo(id, idType) {
    try {
      idType = (idType == "")? "doi": idType 
      const queryPath = this.urlValue + "?id=" + id + "&type=" + idType
      const response = await fetch(queryPath)
      const data = await response.json();
      this.displayPublication(data)
    } catch(error) {
      console.error("Error fetching response for " + id, error)
    }
  }

  displayPublication(data) {
    const type = data['type']
    // Do not display if the type of the item is a dataset
    if(type == 'dataset')
      return

    const title = data['title']
    var URL = ''
    if('primary_location' in data && 'landing_page_url' in data['primary_location']) {
      URL = data['primary_location']['landing_page_url']
    } else if ('doi' in data) {
      URL = data['doi']
    }

    if (URL != '') {
      this.publicationTarget.innerHTML = "<a href='" + URL + "' target='blank'>" + title + "</a>"
    }
  }

}