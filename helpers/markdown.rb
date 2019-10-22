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
    h3(html)
    adsense(html)
    table_of_contents(html)
    in_article_link(html)
    html
  end

  def code_block_language(html)
    html.gsub!(%r{<p>lang:(.*)</p>}, %(<div class="language-tag"><B>▼ \\1</B></div>))
  end

  def h2(html)
    html.scan(%r{<h2>.*</h2>}).each_with_index do |_, i|
      html.sub!(%r{<h2>(.*)</h2>}, %(<div class="text-sub-title"><h2 id="h2_title_#{i}" class="sub-title-border">&nbsp;\\1</h2></div>))
    end
  end

  def h3(html)
    html.scan(%r{<h3>.*</h3>}).each_with_index do |_, i|
      html.sub(%r{<h3>(.*)</h3>}, %(<h3 id="h3_title_#{i}">\\1</h3>))
    end
  end

  def adsense(html)
    html.gsub!(%r{<p>--adsense--</p>}, %[<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:block; text-align:center;"data-ad-layout="in-article"data-ad-format="fluid"data-ad-client="ca-pub-7031203229342761"data-ad-slot="7220498796"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>])
  end

  def table_of_contents(html)
    html.sub!(%r{<p>--toc--</p>}, %(<div class="table-of-contents"></div>))
  end

  def in_article_link(html)
    in_article_link_regxp = %r{<p>--!\[(.*)\]</p>}

    html.scan(in_article_link_regxp).each do |_|
      if in_article_link_regxp =~ html
        post = Post.find_by(id: $~[1])
        html.sub!(in_article_link_regxp, %(<div><a href="../articles/#{post&.id}" class="in-article-link-item in-article-link-fly"><article class="article-inside"><img src="../img/#{post&.top_picture}" alt=""><div><p><span class="date">Posted on #{post&.created_at.strftime('%Y/%m/%d')}</span><br>#{post&.title}</p></div></article></a></div>))
      end
    end
  end
end
