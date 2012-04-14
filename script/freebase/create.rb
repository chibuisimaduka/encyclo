#!/usr/bin/ruby

@parent_id = ARGV[0]
@type = ARGV[1]

raise "Missing freebase type or parent id!" unless @parent_id and @type

@parent_id = @parent_id.to_i

WEBMASTER = User.find(9)
ENGLISH = Language.find(2)

FreebaseEntity.find_all_by_freebase_type(@type).each do |e|
  entity = Entity.create({parent_id: @parent_id, freebase_id: e.freebase_id}, WEBMASTER, ENGLISH, e.name)
  entity.names.first.save!
end
