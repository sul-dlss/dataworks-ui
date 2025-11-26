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
    this.idTypeHash = this.collectByIdType()
    const _this = this
    var batchSize = 50
    for(const idType in this.idTypeHash) {
      var ids = _this.idTypeHash[idType]
      if(ids.length < (batchSize + 1)) {
        _this.openAlexInfo(ids, idType)
      } else {
       _this.batchRequests(ids, idType)
      }
    }
  }

  async batchRequests(ids, idType) {
     // Break out requests into batches of no more than 50
     var counter = 0
     var batchSize = 50
     var delayCounter = 0
     while(counter < ids.length) {
       var queryIds = ids.slice(counter, counter + batchSize)
       counter += batchSize
       delayCounter++
       this.openAlexInfo(queryIds, idType)
       // Rate limiting is about 5 requests per second
       // so we introduce a delay after every 5 requests
       if(delayCounter == 4) {
        delayCounter = 0
        await this.delay(1000)
       }
     }
  }

  

  // We will combine cals for different ids
  collectByIdType() {
    var idTypeHash = {}
    this.publicationTargets.forEach((pub) => {
      var id = pub.getAttribute('api-id')
      var idType = pub.getAttribute('api-id-type') || 'DOI'
      if(id != null) {
        if(! (idType in idTypeHash)) {
          idTypeHash[idType] = []
        }
        idTypeHash[idType].push(id)
      }
    })
    return idTypeHash
  }

  delay(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }

  // id = array of ids
  async openAlexInfo(ids, idType) {
    try {
      const queryPath = this.constructQueryPath(ids, idType)
      const response = await fetch(queryPath)
      const data = await response.json();
      this.displayPublications(data, idType)
    } catch(error) {
      console.error("Error fetching response for " + ids, error)
    }
  }

  constructQueryPath(ids, idType) {
    var idParams = ids.map(id => `ids[]=${id}`).join('&')
    return this.urlValue + "?" + idParams + "&type=" + idType
  }


  // Data for multiple publications is returned
  displayPublications(data, idType) {
    const _this = this
    const results = data['results'] 
    results.forEach((result) => {
      var type = result['type']
      // Do not display if the type of the item is a dataset
      if(type == 'dataset')
        return

      var title = idType == 'ISSN'? result['display_name'] : result['title']
      if(title == '') {
        title = 'Link'
      }
      var URL = _this.URLLink(result)
      var year = _this.yearDisplay(result)
      var authorship = _this.authorshipDisplay(result)
      var targetId = _this.queryId(result, idType)

      var displayHTML = ''
      if (URL != '') {
        var pubTarget = _this.publicationTargets.find((pub) => pub.getAttribute('api-id') === targetId)
        displayHTML = authorship + year + "<a href='" + URL + "' target='blank'>" + title + "</a>"
      } else {
        displayHTML = authorship + year +  title
      }
      pubTarget.innerHTML = displayHTML
    })
  }

  // With an individual result from OpenAlex, we can determine the original id we queried for
  queryId(data, idType) {
    var qid = data['id']
    switch(idType) {
      case 'OpenAlex':
        qid = data['id']
        var prefix = 'https://openalex.org/'
        if(qid.startsWith(prefix)) {
          qid = qid.substring(prefix.length)
        }
        break;
      case 'PMID':
        qid = data['ids']['pmid']
        var prefix = 'https://pubmed.ncbi.nlm.nih.gov/'
        if(qid.startsWith(prefix)) {
          qid = qid.substring(prefix.length)
        }
        break;
      case 'ISSN':
        // ISSNs return an array
        // We can just check the first one for now
        qid = data['issn'][0]
        break;
      default:
        qid = data['doi']
        var prefix = 'https://doi.org/'
        if(qid.startsWith(prefix)) {
          qid = qid.substring(prefix.length)
        }
    }
    return qid
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