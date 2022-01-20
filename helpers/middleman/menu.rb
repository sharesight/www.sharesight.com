load File::expand_path('./locale.rb', __dir__)
load File::expand_path('./page.rb', __dir__)

module MiddlemanMenuHelpers
  include MiddlemanLocaleHelpers # for current_locale_obj method
  include MiddlemanPageHelpers # for locale_page method

  def get_menu_config(locale_obj: current_locale_obj, professional: false)
    return [
      get_features_menu(locale_obj: locale_obj, professional: professional),
      get_benefits_menu(locale_obj: locale_obj, professional: professional),
      get_pricing_menu(locale_obj: locale_obj, professional: professional),
      get_resources_menu(locale_obj: locale_obj, professional: professional)
    ]
  end

  private

  def get_pricing_href(locale_obj: current_locale_obj, professional: false)
    return '#pricing' if professional
    
    return localize_url('pricing', locale_id: locale_obj[:id])
  end

  def get_features_menu(locale_obj: current_locale_obj, professional: false)
    return {
      label: 'Features',
      rows: [
        {
          columns: [
            {
              label: 'Features',
              links: [
                {
                  icon: 'trend-up',
                  icon_hover: 'chart-line-up-bold',
                  label: 'Performance',
                  href: localize_path('investment-portfolio-performance', locale_id: locale_obj[:id]),
                  title: "Investment Portfolio Performance | #{locale_obj[:append_title]}",
                },
                {
                  icon: 'coin',
                  label: 'Dividends',
                  href: localize_path('dividend-tracker', locale_id: locale_obj[:id]),
                  title: "Dividend Tracker | Track Your Dividends | #{locale_obj[:append_title]}",
                },
                {
                  icon: 'receipt',
                  icon_hover: 'article-fill',
                  label: 'Tax Reporting',
                  href: localize_url('investment-portfolio-tax', locale_id: locale_obj[:id]),
                  title: locale_page(page: 'investment-portfolio-tax', locale_obj: locale_obj)[:page_title],
                }
              ]
            },
            {
              label: 'What we Track',
              links: [
                {
                  icon: 'squares-four',
                  icon_hover: 'grid-four-fill',
                  label: 'Supported Investments',
                  title: "Supported Investments | #{locale_obj[:append_title]}",
                  href: localize_url('faq', locale_id: locale_obj[:id]) + "#what-can-i-track-in-sharesight",
                },
                {
                  icon: 'globe-hemisphere-west',
                  icon_hover: 'globe-hemisphere-east-fill',
                  label: 'Supported Exchanges',
                  title: "Supported Exchanges | #{locale_obj[:append_title]}",
                  href: localize_url('faq', locale_id: locale_obj[:id]) + "#which-stock-exchanges-does-sharesight-support",
                },
                {
                  icon: 'bank',
                  label: 'Supported Brokers',
                  title: "Supported Brokers | #{locale_obj[:append_title]}",
                  href: localize_url('supported-brokers', locale_id: locale_obj[:id], base_url: config[:help_url]),
                }
              ]
            }
          ]
        },
        {
          class: 'menu__background',
          columns: [
            {
              links: [
                {
                  visible_desktop: false,
                  label: 'Pricing',
                  icon: 'wallet',
                  href: get_pricing_href(locale_obj: locale_obj, professional: professional), # this goes to an anchor for pro
                  title: "Pricing | #{locale_obj[:append_title]}",
                },
                {
                  icon: 'question',
                  label: 'Frequently Asked Questions',
                  title: "FAQ | #{locale_obj[:append_title]}",
                  href: localize_url('faq', locale_id: locale_obj[:id]),
                },
              ]
            },
            {
              links: [
                {
                  icon: 'shield',
                  icon_hover: 'shield-check-fill',
                  label: 'Data Security',
                  title: "Data Security | #{locale_obj[:append_title]}",
                  href: localize_url('how-sharesight-protects-your-data', locale_id: locale_obj[:id], base_url: config[:help_url])
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def get_benefits_menu(locale_obj: current_locale_obj, professional: false)
    return {
      label: 'Benefits',
      rows: [
        {
          columns: [
            {
              label_mobile: 'Benefits',
              links: [
                {
                  icon: 'user',
                  label: 'Investors',
                  title: locale_page(page: 'investors', locale_obj: locale_obj)[:page_title],
                  href: localize_url('investors', locale_id: locale_obj[:id]),
                  description: 'Join **300,000+** investors who track their portfolios with Sharesight.',
                },
                # FYI: You can add "child links" here to look like they're nested under this.
                # This is kept around for future reference.
                # {
                #   label: 'Read the Reviews',
                #   title: locale_page(page: 'reviews', locale_obj: locale_obj)[:page_title],
                #   href: localize_url('reviews', locale_id: locale_obj[:id]),
                # },
                {
                  icon: 'users',
                  label: 'Finance Professionals',
                  title: locale_page(page: 'pro', locale_obj: locale_obj)[:page_title],
                  href: localize_url('pro', locale_id: locale_obj[:id]),
                  description: 'Grow your business with **Sharesight Pro**.'
                },
                {
                  icon: 'buildings',
                  label: 'Finance Companies',
                  title: locale_page(page: 'become-a-partner', locale_obj: locale_obj)[:page_title],
                  href: localize_url('become-a-partner', locale_id: locale_obj[:id]),
                  description: 'Connect with Sharesight to power your business.'
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def get_pricing_menu(locale_obj: current_locale_obj, professional: false)
    return {
      visible_mobile: false,
      label: 'Pricing',
      href: get_pricing_href(locale_obj: locale_obj, professional: professional), # this goes to an anchor for pro
      title: "Pricing | #{locale_obj[:append_title]}",
    }
  end

  def get_resources_menu(locale_obj: current_locale_obj, professional: false)
    return {
      label: 'Resources',
      class: 'menu--lg',
      rows: [
        {
          columns: [
            {
              label: 'Company',
              links: [
                {
                  icon: 'magnifying-glass',
                  label: 'About Sharesight',
                  title: "About Us | #{locale_obj[:append_title]}",
                  href: localize_url('about-sharesight', locale_id: locale_obj[:id])
                },
                {
                  icon: 'user-rectangle',
                  label: 'Executive Team',
                  title: "Executive Team | #{locale_obj[:append_title]}",
                  href: localize_url('team', locale_id: locale_obj[:id]),
                },
                # TODO: Once there's content, we could add these.  If not, delete.
                # {
                #   icon: 'briefcase',
                #   title: 'Careers',
                #   href: '/NOT-YET-CREATED',
                # },
                # {
                #   icon: 'megaphone-simple',
                #   title: 'Media Center',
                #   href: '/NOT-YET-CREATED',
                # },
                {
                  icon: 'smiley',
                  icon_hover: 'smiley-wink-fill',
                  label: 'Reviews',
                  title: locale_page(page: 'reviews', locale_obj: locale_obj)[:page_title],
                  href: localize_url('reviews', locale_id: locale_obj[:id]),
                }
              ],
            }, {
              label: 'Work with Us',
              links: [
                {
                  icon: 'identification-card',
                  label: 'Partner Directory',
                  title: locale_page(page: 'partners', locale_obj: locale_obj)[:page_title],
                  href: localize_url('partners', locale_id: locale_obj[:id]),
                },
                {
                  icon: 'handshake',
                  label: 'Become a Partner',
                  title: locale_page(page: 'become-a-partner', locale_obj: locale_obj)[:page_title],
                  href: localize_url('become-a-partner', locale_id: locale_obj[:id]),
                },
                {
                  icon: 'share-network',
                  icon_hover: 'fire-fill',
                  label: 'Become an Affiliate',
                  title: "Affiliates | #{locale_obj[:append_title]}",
                  href: localize_url('affiliates', locale_id: locale_obj[:id]),
                },
                {
                  icon: 'envelope-simple',
                  icon_hover: 'envelope-simple-open',
                  label: 'sales@sharesight.com',
                  title: 'Email the Sales & Partnerships Team',
                  href: 'mailto:sales@sharesight.com',
                }
              ]
            }, {
              label: 'Resources',
              links: [
                {
                  icon: 'info',
                  label: 'Help Centre',
                  title: "Help Centre | #{locale_obj[:append_title]}",
                  href: localize_url(base_url: config[:help_url], locale_id: locale_obj[:id]),
                },
                {
                  icon: 'pencil-circle',
                  title: 'Read the Sharesight Blog',
                  label: 'Sharesight Blog',
                  href: unlocalized_url('blog'),
                },
                {
                  icon: 'code',
                  label: 'Sharesight API',
                  title: 'Sharesight API Documentation',
                  href: config[:api_url],
                },
                {
                  icon: 'monitor-play',
                  icon_hover: 'monitor-fill',
                  label: 'Webinars & Events',
                  title: "Webinars & Events | #{locale_obj[:append_title]}",
                  href: localize_url('events', locale_id: locale_obj[:id]),
                },
                {
                  icon: 'users',
                  icon_hover: 'users-fill',
                  label: 'Community Forum',
                  title: 'Community Forum',
                  href: unlocalized_url(base_url: config[:community_url]),
                }
              ]
            }
          ]
        },
        {
          visible_mobile: false,
          # For this row, we just use a specific blog partial rather than try to fit it into this format…
          partial: 'partials/header/blog',
        }
      ]
    }
  end

end
