module MobileFu
  module Helper
    JS_ENABLED_DEVICES = %w{iphone ipod ipad mobileexplorer android zune}

    def js_enabled_mobile_device?
      JS_ENABLED_DEVICES.find { |device| is_device? device }
    end

    def stylesheet_link_tag_with_mobilization(*sources)
      mobilized_sources = Array.new

      # Figure out where stylesheets live, which differs depending if the asset
      # pipeline is used or not.
      stylesheets_dir = config.stylesheets_dir # Rails.root/public/stylesheets

      # Look for mobilized stylesheets in the app/assets path if asset pipeline
      # is enabled, because public/stylesheets will be missing in development
      # mode without precompiling assets first, and may also contain multiple
      # stylesheets with similar names because of checksumming during
      # precompilation.
      if Rails.application.config.respond_to?(:assets) # don't break pre-rails3.1
        if Rails.application.config.assets.enabled
          stylesheets_dir = File.join(Rails.root, 'app/assets/stylesheets/')
        end
      end

      device_names = respond_to?(:is_mobile_device?) && is_mobile_device? ? ['mobile', mobile_device.to_s.downcase] : []

      sources.each do |source|
        mobilized_sources << source

        device_names.compact.each do |device_name|
          # support ERB and/or SCSS extensions (e.g., mobile.css.erb, mobile.css.scss.erb)
          possible_source = source.to_s.sub(/\.css.*$/, '') + "_#{device_name}"

          mobilized_files = Dir.glob(File.join(stylesheets_dir, "#{possible_source}.css*")).map { |f| f.sub(stylesheets_dir, '') }
          mobilized_sources += mobilized_files.map { |f| f.sub(/\.css.*/, '') }
        end
      end

      stylesheet_link_tag_without_mobilization *mobilized_sources
    end
  end
end
