helpers do
  def markdown(text)
    render_options = {
      filter_html: false, # htmlタグの入力を無効化(サニタイズ)
      hard_wrap:   true,  # 空行を改行ではなく、改行を改行に変換
      link_attributes: { rel: 'noopener', target: '_blank' }
    }
    # renderer = Redcarpet::Render::HTML.new(render_options)
    renderer = ::CustomMarkdownRenderer.new(render_options)

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
    code_block_language(html)
    h2(html)
    html
  end

  def code_block_language(text)
    text.gsub!(%r{<p>lang:(.*)</p>}, %(<div class="language-tag"><B>▼ \\1</B></div>))
  end

  def h2(text)
    text.scan(%r{<h2>.*</h2>}).each_with_index do |_, i|
      text.sub!(%r{<h2>(.*)</h2>}, %(<div class="text-sub-title"><h2 id="h2_title_#{i}" class="sub-title-border">&nbsp;\\1</h2></div>))
    end
  end
end
