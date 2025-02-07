module Jekyll
  class FrontMatterParser < Generator
    def generate(site)
      baseurl = site.config['baseurl']
      site.posts.docs.each do |post|
        post.data.each do |key, value|
          post.data[key] = process_value(value, baseurl, post)
        end
      end
    end

    def process_value(value, baseurl, post)
      case value
      when String
        context = {
          'site' => { 'baseurl' => baseurl },
          'page' => post.to_liquid
        }
        Liquid::Template.parse(value).render(context)
      when Array
        value.map { |item| process_value(item, baseurl, post) }
      when Hash
        processed_hash = {}
        value.each do |key, val|
          processed_hash[key] = process_value(val, baseurl, post)
        end
        processed_hash
      else
        value
      end
    end
  end
end