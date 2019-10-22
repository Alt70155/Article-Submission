helpers do
  class CustomMarkdownRenderer < Redcarpet::Render::HTML
    # コードブロックのrougeとredcarpetを接続
    include Rouge::Plugins::Redcarpet

    #
    # Redcarpetのpreprocessメソッドをオーバーライドしてカスタムタグを実行
    # @param  [String] text markdownで記述された記事
    # @return [String] text 独自タグをHTMLタグに変換した記事
    #
    # def preprocess(text)
    #   replace_text = self.class.table_of_contents(text)
    #   replace_text = self.class.h2(replace_text)
    #   replace_text = self.class.h3(replace_text)
    #   replace_text = self.class.adsense(replace_text)
    #   replace_text = self.class.in_article_link(replace_text)
    #   replace_text
    # end

    class << self

      #
      # --toc--タグをdivタグに変換し、JSで子要素に目次を生成する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text --toc--をdivにした記事
      #
      def table_of_contents(text)
        text.sub(/--toc--/, %(<div class="table-of-contents"></div>))
      end

      #
      # ##タグをカスタムしたh2タグに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text ##をカスタムh2にした記事
      #
      def h2(text)
        text.scan(/^##\s.*$/).each_with_index do |_, i|
          text = text.sub(/^##\s(.*$)/, %(<div class="text-sub-title"><h2 id="h2_title_#{i}" class="sub-title-border">&nbsp;\\1</h2></div>))
        end
        text
      end

      #
      # ###タグをカスタムしたh3タグに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text ###をカスタムh3にした記事
      #
      def h3(text)
        text.scan(/^###\s.*$/).each_with_index do |_, i|
          text = text.sub(/^###\s(.*)$/, %(<h3 id="h3_title_#{i}">\\1</h3>))
        end
        text
      end

      #
      # --adsense--タグを広告用スクリプトに変換する。
      # @param  [String] text markdownで記述された記事
      # @return [String] text --adsense--を広告用スクリプトにした記事
      #
      def adsense(text)
        text.gsub(/--adsense--/, %[<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script><ins class="adsbygoogle" style="display:block; text-align:center;"data-ad-layout="in-article"data-ad-format="fluid"data-ad-client="ca-pub-7031203229342761"data-ad-slot="7220498796"></ins><script>(adsbygoogle = window.adsbygoogle || []).push({});</script>])
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
            text = text.sub(in_article_link_regxp, %(<div><a href="../articles/#{post.id}" class="in-article-link-item in-article-link-fly"><article class="article-inside"><img src="../img/#{post.top_picture}" alt=""><div><p><span class="date">Posted on #{post.created_at.strftime('%Y/%m/%d')}</span><br>#{post.title}</p></div></article></a></div>))
          end
        end
        text
      end

    end
  end
end
