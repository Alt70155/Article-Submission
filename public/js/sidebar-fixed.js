const HALFWAY_POINT_WIDTH = 1080
const _window       = window
const _rightBar     = document.querySelector('.right-bar')
const _textContent  = document.querySelector('.text-content')
const _content      = document.querySelector('.content')
const headerHeight  = document.querySelector('header').clientHeight
const _asideBox     = document.querySelector('.aside-box')
// 二個目のothertitleを取得
const _otherTitle   = document.querySelectorAll('.other-title')[1]
// フッター要素までのtopからの絶対座標を取得
// スクロールされたままリロードされた場合ズレるのでスクロール量も足しておく
const footerTop     = document.querySelector('footer')
  .getBoundingClientRect().top + _window.pageYOffset - _rightBar.clientHeight

// サイドバーのposition:left値を更新する関数
// 画面サイズが変わるたびにleft値を変更する
const updateLeftValOfSidebar = () => {
  // .contentの右隣にあるため、ブラウザの左端から.contentの右までの距離を調べる
  // まずはpaddingの値を計算して足す
  const contentWidthStr = _window.getComputedStyle(_content).width
  // 数値だけ取り出して数値型に変換
  const contentWidth = Number(contentWidthStr.replace(/[^0-9]/g, ''))
  // 片方のpadding値を出すため÷2する
  const paddingVal = (_content.clientWidth - contentWidth) / 2
  // 左からtextcontentの右側までの距離
  const textContentRight = _textContent.getBoundingClientRect().right
  _rightBar.style.left = `${textContentRight + paddingVal + 2}px`
}

// プロフィール部分を飛ばすため位置を取得
const asideBoxMarginBtmStr = _window.getComputedStyle(_asideBox).marginBottom
const asideBoxMarginBtm    = Number(asideBoxMarginBtmStr.replace(/[^0-9]/g, ''))
const asideBoxHeight       = _asideBox.clientHeight + (asideBoxMarginBtm * 1.5)

// メインコンテンツより下(フッター内)の場合のtopの値を計算
// left-barの位置をスクロール量を合わせて固定表示にする
const SIDEBAR_TOP_FIXED_VAL = `${_textContent.getBoundingClientRect().bottom +
  _window.pageYOffset - _rightBar.clientHeight - asideBoxHeight + (asideBoxMarginBtm * 1.5)}px`

const fixSidebarWhenScrolled = () => {
  // スクロール量を取得
  const _windowScrollWeight = _window.pageYOffset
  // console.log(_windowScrollWeight)
  // メインコンテンツ内の場合固定する
  if (_windowScrollWeight > headerHeight + asideBoxHeight && _windowScrollWeight < footerTop) {
    _rightBar.style.top = `${-asideBoxHeight}px`
    _rightBar.classList.add('fixed')
  } else {
    _rightBar.style.top = `${headerHeight + 1}px`
    _rightBar.classList.remove('fixed')
    // メインコンテンツより下(フッター内)の場合
    if (_windowScrollWeight > footerTop) {
      _rightBar.style.top  = SIDEBAR_TOP_FIXED_VAL
    }
  }
}

const windowSizeJudge = () => {
  _rightBar.classList.remove('hidden-item')
  // ブラウザが1080px以上だった場合はサイドバーを表示する
  if (matchMedia(`(min-width: ${HALFWAY_POINT_WIDTH}px)`).matches) {
    _rightBar.classList.add('right-bar')
    _rightBar.classList.remove('right-bar-is-down')
    _otherTitle.classList.add('display-none')
    fixSidebarWhenScrolled()
    updateLeftValOfSidebar()
    _window.addEventListener('scroll', fixSidebarWhenScrolled)
    _window.addEventListener('resize', updateLeftValOfSidebar)
  } else {
    _window.removeEventListener('scroll', fixSidebarWhenScrolled)
    _rightBar.classList.remove('fixed', 'right-bar')
    _rightBar.classList.add('right-bar-is-down')
    _otherTitle.classList.remove('display-none')
  }
}

windowSizeJudge()
_window.addEventListener('resize', () => windowSizeJudge())
