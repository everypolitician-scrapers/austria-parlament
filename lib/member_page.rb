# frozen_string_literal: true

require_rel 'page'

class MemberPage < Page
  field :id do
    url.to_s[/PAD_(\d+)/, 1]
  end

  field :name do
    noko.css('h1#inhalt').text.tidy
  end

  field :source do
    url.to_s
  end
end
