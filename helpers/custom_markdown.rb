helpers do
  class CustomMarkdownRenderer < Redcarpet::Render::HTML
    # コードブロックのrougeとredcarpetを接続
    include Rouge::Plugins::Redcarpet

    #
    # Redcarpetのpreprocessメソッドをオーバーライドしてカスタムタグを実行
    # @param  [String] text markdownで記述された記事
    # @return [String] text 独自タグをHTMLタグに変換した記事
    #
    def preprocess(text)
      self.class.table_of_contents(text)
      self.class.h2(text)
      self.class.h3(text)
      self.class.adsense(text)
      self.class.code_block_language(text)
      self.class.in_article_link(text)
      text
    end

    class << self

      #
      # --toc--タグをdivタグに変換し、JSで子要素に目次を生成する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text --toc--をdivにした記事
      #
      def table_of_contents(text)
        text.sub!(/--toc--/, %(<div class="table-of-contents"></div>))
      end

      #
      # ##タグをカスタムしたh2タグに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text ##をカスタムh2にした記事
      #
      def h2(text)
        text.scan(/^##\s.*$/).each_with_index do |_, i|
          text.sub!(/^##\s(.*$)/, %(<div class="text-sub-title"><h2 id="h2_title_#{i}" class="sub-title-border">&nbsp;\\1</h2></div>))
        end
      end

      #
      # ###タグをカスタムしたh3タグに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text ###をカスタムh3にした記事
      #
      def h3(text)
        text.scan(/^###\s.*$/).each_with_index do |_, i|
          text.sub!(/^###\s(.*)$/, %(<h3 id="h3_title_#{i}">\\1</h3>))
        end
      end

      #
      # --adsense--タグを広告用スクリプトに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text --adsense--を広告用スクリプトにした記事
      #
      def adsense(text)
        text.gsub!(/--adsense--/, %[<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:block; text-align:center;"data-ad-layout="in-article"data-ad-format="fluid"data-ad-client="ca-pub-7031203229342761"data-ad-slot="7220498796"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>])
      end

      #
      # lang:lang_nameタグをカスタムdivに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text lang:lang_nameタグをカスタムdivにした記事
      #
      def code_block_language(text)
        text.gsub!(/lang:(.*)/, %(<div class="language-tag"><B>▼ \\1</B></div>))
      end

      #
      # --![post_id]タグを記事内リンクに変換する
      # @param  [String] text markdownで記述された記事
      # @return [String] text --![post_id]タグを記事内リンクに変換した記事
      #
      def in_article_link(text)
        in_article_link_regxp = /--!\[(.*)\]/

        text.scan(in_article_link_regxp).each do |_|
          if in_article_link_regxp =~ text
            post = Post.find_by(id: $~[1])
            text.sub!(in_article_link_regxp, %(<div class="in-article-link-out"><a href="../articles/#{post.id}" target="_blank"><div class="in-article-link"><img src="../img/#{post.top_picture}" alt="" class="portfolio-image-deco in-article-link-img"><h3>#{post.title}</h3></div></a></div>))
          end
        end
      end

    end
  end
end
