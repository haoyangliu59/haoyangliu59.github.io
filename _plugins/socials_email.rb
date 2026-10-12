# frozen_string_literal: true

# Joins `email_user` and `email_domain` in _data/socials.yml into the `email` entry that
# jekyll-socials expects, keeping its position so the icon order is unchanged. The repository is
# public, so the address is never written out whole in the source; on the page, `protect_email`
# (al_email_protect) splits it again.
Jekyll::Hooks.register :site, :post_read do |site|
  socials = site.data["socials"]
  next unless socials.is_a?(Hash) && socials["email_user"] && socials["email_domain"]

  site.data["socials"] = socials.each_with_object({}) do |(key, value), joined|
    case key
    when "email_user" then joined["email"] = "#{value}@#{socials['email_domain']}"
    when "email_domain" then next
    else joined[key] = value
    end
  end
end
