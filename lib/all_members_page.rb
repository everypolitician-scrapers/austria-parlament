# frozen_string_literal: true
require_rel 'page'

class AllMembersPage < Page
  field :members do
    member_table.css('tr').drop(1).map do |tr|
      td = tr.css('td')
      {
        name:    td[0].text.tidy,
        faction: td[1].text.split(/,\s+/).map(&:tidy),
        terms:   td[2].text.split(/,\s+/).map(&:tidy),
        state:   td[3].text.split(/,\s+/).map(&:tidy),
        url:     absolute_url(td[0].css('a/@href').text),
      }
    end
  end

  private

  def member_table
    mt = noko.css('.tabelle') or raise 'No member table'
    raise 'Too many member tables' if mt.count > 1
    mt
  end
end
