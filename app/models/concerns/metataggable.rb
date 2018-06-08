#
module Metataggable
  extend ActiveSupport::Concern

  def metatags
    {
      title:       meta_title,
      description: meta_description,
      image_src:   meta_image_url,
      og:          og_metatags
    }
  end

  def og_metatags
    {
      title:       meta_title,
      description: meta_description,
      image:       meta_image
    }
  end

  def meta_title
    t = send(self.class.acts_as_label)
    return Setting.app_title if t.blank?
    t
  rescue
    Setting.app_title
  end

  def meta_description
    d = send(self.class.acts_as_description)
    return Setting.app_description if d.blank?
    d
  rescue
    Setting.app_description
  end

  def meta_image_url
    i = meta_image
    return nil if i.nil? || !i.key?(:_)

    i[:_]
  end

  def meta_image
    main_image_info || cover_info || Setting.gimmick_meta_info
  end

  def main_image_info
    return nil unless self.class.respond_to?(:main_image?)
    main_image.meta_info
  end

  def cover_info
    return nil unless self.class.respond_to?(:cover?)
    cover.meta_info
  end
end
