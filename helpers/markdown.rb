helpers do
  def markdown(text)
    render_options = {
      filter_html: false, # htmlタグの入力を無効化(サニタイズ)
      hard_wrap:   true,  # 空行を改行ではなく、改行を改行に変換
      link_attributes: { rel: 'noopener', target: "_blank" }
    }
    renderer = Redcarpet::Render::HTML.new(render_options)

    extensions = {
      autolink:            true,
      fenced_code_blocks:  true,
      lax_spacing:         true,
      no_intra_emphasis:   true,
      strikethrough:       true,
      superscript:         true,
      tables:              true,
      space_after_headers: true # #の後に空行がないと見出しと認めない
    }
    html = Redcarpet::Markdown.new(renderer, extensions).render(text)
    replace_html(html)
  end

  def replace_html(html)
    html.gsub!(/<h2>/, '<div class="text-sub-title"><h2 class="sub-title-border">&nbsp;')
       &.gsub!(%r{</h2>}, '</h2></div>')
    html.gsub!(/--adsense--/, %[
      <script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
      <ins class="adsbygoogle"
           style="display:block; text-align:center;"
           data-ad-layout="in-article"
           data-ad-format="fluid"
           data-ad-client="ca-pub-7031203229342761"
           data-ad-slot="7220498796"></ins>
      <script>
           (adsbygoogle = window.adsbygoogle || []).push({});
      </script>
    ])
    # コードブロックが何言語かをcodeのclassから探して取り出す
    str_len = 'code class="'.length
    program_language_list = html.scan(/code class=".*"/).map { |m| m[str_len..-2] }
    program_language_list.each do |p|
      html.sub!(/<pre><code .*>/, %(<div class="language-tag"><B>▼ #{p}</B></div><pre class="prettyprint linenums"><code>))
    end
    html
  end
end
