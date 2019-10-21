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
    Redcarpet::Markdown.new(renderer, extensions).render(text)
  end
end
