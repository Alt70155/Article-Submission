// コードブロックのmax-width値更新
const prettyPrintList = document.querySelectorAll('.prettyprint')

const codeBlockMaxWidthChange = () => {
  const textContent      = document.querySelectorAll('.text-content')
  const articlePadding   = 60
  const articleMaxWidth  = 860
  const windowInnerWidth = window.innerWidth

  if (windowInnerWidth <= articleMaxWidth) {
    prettyPrintList.forEach((elem) => {
      elem.style.maxWidth = `${windowInnerWidth - articlePadding}px`
    })
  } else {
    prettyPrintList.forEach((elem) => {
      elem.style.maxWidth = `${textContent.clientWidth}px`
    })
  }
}

if (prettyPrintList.length) {
  // リサイズ時にしか実行されないから直す
  codeBlockMaxWidthChange()
  window.addEventListener('resize', codeBlockMaxWidthChange)
}
