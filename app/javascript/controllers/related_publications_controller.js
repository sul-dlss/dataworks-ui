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
      this.displayPublication(data, idType)
    } catch(error) {
      console.error("Error fetching response for " + id, error)
    }
  }

  displayPublication(data, idType) {
    const type = data['type']
    // Do not display if the type of the item is a dataset
    if(type == 'dataset')
      return

    const title = idType == 'ISSN'? data['display_name'] : data['title']
    const URL = this.URLLink(data)
    const year = this.yearDisplay(data)
    const authorship = this.authorshipDisplay(data)

    if (URL != '') {
      this.publicationTarget.innerHTML = "<a href='" + URL + "' target='blank'>" + authorship + year + title + "</a>"
    }
  }

  URLLink(data) {
    var URL = ''
    if('primary_location' in data && 'landing_page_url' in data['primary_location']) {
      URL = data['primary_location']['landing_page_url']
    } else if('homepage_url' in data) {
      URL = data['homepage_url']
    } else if ('doi' in data) {
      URL = data['doi']
    }
    return URL
  }

  yearDisplay(data) {
    var yearDisplay = ''
    if('publication_year' in data) {
      yearDisplay = '(' + data['publication_year'] + '). '
    }
    return yearDisplay
  }
  authorshipDisplay(data){
    var authorDisplay = ''
    if('authorships' in data && data['authorships'].length > 0) {
      const authorships = data['authorships']
      // Get the first three authors  
      const authorshipsNumber = authorships.length
     
      const mappedDisplay = authorships.slice(0, 3).map(function(authorship) {
        if('author' in authorship && 'display_name' in authorship['author']) {
          return authorship['author']['display_name']
        }
        return ''
      })

      authorDisplay = mappedDisplay.join(', ')
      if(authorshipsNumber > 3) {
        authorDisplay = authorDisplay + ', et al'
      }
      authorDisplay = authorDisplay + '. '
    }
    return authorDisplay
  }

}