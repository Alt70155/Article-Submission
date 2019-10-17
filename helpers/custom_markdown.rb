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
      # text.sub!(%r{--toc--}, %(<div class="table-of-contents"></div>))
      self.class.table_of_contents(text)
      text
    end

    class << self

      #
      # --toc--タグをdivタグに変換し、JSで子要素に目次を生成する。
      #
      def table_of_contents(text)
        text.sub!(%r{--toc--}, %(<div class="table-of-contents"></div>))
      end
    end

  end
end
