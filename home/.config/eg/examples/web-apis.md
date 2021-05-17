# Web APIs

## Google Books

Get a list of volumes given an author name.

    vol_info="categories,description,imageLinks,industryIdentifiers,infoLink,pageCount,printType,publishedDate,publisher,title"
    http --pretty all --style solarized GET "https://www.googleapis.com/books/v1/volumes" \
        fields=="kind,totalItems,items(id,etag,kind,volumeInfo($vol_info))" \
        langRestrict==en maxResults==40 startIndex==0 \
        q=="inauthor:Terry Pratchett" | less -R

