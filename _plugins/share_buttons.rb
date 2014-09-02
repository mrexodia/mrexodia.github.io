module Jekyll
    module ShareButtonsFilter
      def share_buttons url
        full_url = @context.registers[:site].config['production_url'] + url

        <<-HTML
          <div class="buttons">
            <a href="https://twitter.com/share"
              class="twitter-share-button"
              data-url="#{full_url}"
              data-via="twitterapi"
              data-lang="en">
            </a>

            <div class="google_plus">
              <div class="g-plusone"
                data-href="#{full_url}"
                data-size="medium"
                data-annotation="bubble">
              </div>
            </div>
          </div>
        HTML
      end
    end
  end

  Liquid::Template.register_filter Jekyll::ShareButtonsFilter