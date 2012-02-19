FactoryGirl.define do

  factory :entity do
    sequence :rank, 50 do |n|
      n.to_f/10.0
    end
    user
    names {|name| names.association(:name)}
  end

  factory :child_and_parent_entity do
    association :parent, :factory => :childless_orphan_entity
    entities { |entities| entities.association(:childless_orphan_entity) }
  end
  
  factory :childless_orphan_entity, :parent => :entity do
    parent nil
  end

  factory :user do
    sequence(:email) {|n|  "john_doe_#{n}@encyclo.com" }
    password "foobar"
    password_confirmation { password }
    is_ip_address false

    factory :ip_address do
      is_ip_address true
    end
  end

  factory :name do
    sequence :value do |n|
      "Some name #{n}"
    end
    language
    possible_name_spellings {|possible_name_spellings| possible_name_spellings.association(:possible_name_spelling, :spelling => value)}
  end
  
  factory :language do
    name "english"
  end

  factory :french_language do
    name "french"
  end

  factory :association_definition do
    entity

    factory :nested_association_definition do
      association :nested_entity, :factory => :entity
    end

    trait :many_to_many do
      entity_has_many true
      associated_entity_has_many true
    end

    trait :one_to_many do
      entity_has_many false
      associated_entity_has_many true
    end

    trait :one_to_one do
      entity_has_many false
      associated_entity_has_many false
    end

    trait :many_to_one do
      entity_has_many true
      associated_entity_has_many false
    end

    one_to_many
  end

  factory :association do
    association :definition, :factory => :association_definition
    entity
    association :associated_entity, :factory => :entity
    user
  end

  factory :component do
    entity
    association :associated_entity, :factory => :entity
    user
  end

  factory :delete_request do
    user
    #destroyable
    considered_destroyed false
  end

  factory :document_type do
    name "review"
  end

  factory :document do
    name "Some document name"
    source "http://www.some_url.ca/"
    description "A description about the content about something."
    content "Some content about something."
    #document_types
    language
    user
    
    factory :local_document do
      source  "http://www.encyclo.com"
    end
  end

  factory :possible_spelling_edit_request, :class => EditRequest do
    agreeing_users {|d| Factory.create_list(:user, 2, :edit_requests => [d]) }
    association :editable, :factory => :possible_name_spelling
  #  after_create 
  end

  #factory :editable_edit_request do
  #end

  factory :possible_name_spelling do
    spelling "Some name"
  end

end
