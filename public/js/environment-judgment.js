const userAgent = navigator.userAgent.toLowerCase();

if ( userAgent.indexOf('msie')    === -1 &&
     userAgent.indexOf('trident') === -1 &&
     userAgent.indexOf('edge')    === -1 &&
     userAgent.indexOf('chrome')  !== -1 &&
     userAgent.indexOf('windows') !== -1 ) {
  const linkTagPaddingVal  = '11px 18px'
  const allowValPaddingVal = '10px 16px'
  document.querySelectorAll('.pagination a').forEach( node => {
    node.style.padding = node.textContent === '<' || node.textContent === '>' ? allowValPaddingVal : linkTagPaddingVal
  })
  document.querySelector('.current').style.padding = linkTagPaddingVal
  document.querySelector('.pagination .disabled').style.padding = '11px 16px'
}
