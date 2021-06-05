# Web APIs

## Google Books

Get a list of volumes given an author name.

    vol_info="categories,description,imageLinks,industryIdentifiers,infoLink,pageCount,printType,publishedDate,publisher,title"
    http --pretty all --style solarized GET "https://www.googleapis.com/books/v1/volumes" \
        fields=="kind,totalItems,items(id,etag,kind,volumeInfo($vol_info))" \
        langRestrict==en maxResults==40 startIndex==0 \
        q=="inauthor:Terry Pratchett" | less -R


## IMDb


## TVdb


## Trakt

Access to the *trakt.tv* API needs the https://pypi.org/project/trakt/ package from PyPI.

    python3 -m pip install --user trakt==3.1.0

Authorization is needed for most data access, even read-only.

    import os
    from trakt import init

    trakt_auth = [os.getenv(x) for x in ('TRAKT_USER', 'TRAKT_CLIENT_ID', 'TRAKT_CLIENT_SECRET')]
    init(trakt_auth[0], client_id=trakt_auth[1], client_secret=trakt_auth[2])

Print data for a specific movie by IMDb ID.

    from pprint import pprint
    from trakt import movies

    m = movies.Movie('tt1727824')
    pprint(vars(m))

