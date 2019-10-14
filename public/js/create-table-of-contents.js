const createTableOfContents = () => {
  const tableOfContents = document.querySelector('.table-of-contents')

  if (!!tableOfContents) {
    const subTitleList    = document.querySelectorAll('.sub-title-border')
    const ul = document.createElement('ul')

    for (let i = 1; i < subTitleList.length; i++) {
      const li = document.createElement('li')
      const a  = document.createElement('a')

      a.href = `#h2_title_${i}`
      a.textContent = subTitleList[i].textContent
      li.appendChild(a)
      ul.appendChild(li)
    }
    tableOfContents.appendChild(ul)
  }
}
createTableOfContents()
