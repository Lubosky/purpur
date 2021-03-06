require_relative "purpur/version"

module Purpur

  ICON_SIZES = ({
    xsmall: 'xsm',
    extrasmall: 'xsm',
    xsm: 'xsm',
    small: 'sm',
    sm: 'sm',
    medium: 'm',
    m: 'm',
    md: 'm',
    large: 'lg',
    lg: 'lg',
    big: 'xl',
    xl: 'xl',
    huge: 'xxl',
    xxl: 'xxl'
  }).with_indifferent_access
  ICON_SIZES.default_proc = ->(h, i) { Rails.logger.warn("'#{i}' is wrong size of icon. Use one of #{h.keys.join(', ')}"); i.to_s; }

  ICON_EXTENTION = '.svg'

  ICON_SYNONIMS_HASH = if File.exists? File.join("config", "icon_synonims.yml")
    YAML.load(ERB.new(IO.read(File.join("config", "icon_synonims.yml"))).result) || {}
  else
    {}
  end

  class << self

    def icon_size(size)
      ICON_SIZES[size]
    end

    def icon_synonim(key)
      (ICON_SYNONIMS_HASH.with_indifferent_access.tap do |h|
        h.default_proc = ->(_, i) { i.to_s }
      end)[key]
    end

    def icon_key(n)
      case n
      when Symbol, String
        n.downcase
      when Class
        n.name.to_s.downcase
      when Object
        n.class.name.to_s.downcase
      end
    end

    def icon_name(key)
      icon_names[icon_synonim(icon_key(key))]
    end

    def register!
      register_helpers
      register_engine     if rails?
      register_sprockets  if sprockets?
    end

    def rails?
      defined?(::Rails::Engine)
    end

    def sprockets?
      defined?(::Sprockets)
    end

    def root_dir
      File.expand_path "."
    end

    def assets_dir
      File.join(root_dir, 'app', 'assets')
    end

    def images_dir
      File.join(assets_dir, 'icons')
    end

    def icons
      Dir[File.join(self.images_dir, "*#{ICON_EXTENTION}")]
    end

    def icon_names
      Hash[
        self.icons.map {|i|
          [File.basename(i, ICON_EXTENTION), File.basename(i, ICON_EXTENTION)]
        }
      ].tap do |h|
        h.default_proc = ->(_, i) { Rails.logger.warn("'#{i}' is wrong icon name. Use one of #{h.keys.join(', ')}"); i.to_s }
      end
    end

    def sprite_file
      File.join(assets_dir, 'images', 'purpur.svg')
    end

    private

    def register_engine
      require_relative 'purpur/engine'
    end

    def register_sprockets
      Sprockets.append_path(File.join(File.expand_path('../../', __FILE__), 'assets'))
    end

    def register_helpers
      require_relative 'purpur/helpers'
    end

  end
end

Purpur.register!
