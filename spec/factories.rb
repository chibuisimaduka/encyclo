FactoryGirl.define do
  factory :user do
    email  'john_doe@encyclo.com'
    password_hash "$2a$10$SYMloqmm5geGvBagmwn6bO4K73L9oOQubs5qNXvafpk8zQsHp7y.a"
    password_salt "$2a$10$SYMloqmm5geGvBagmwn6bO"
    is_ip_address false

    factory :ip_address do
      is_ip_address true
    end
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
    document_types
    language
    user
    
    factory :local_document do
      source  "http://www.encyclo.com"
    end
  end

  factory :edit_request do
    # editable
  end

  factory :entity do
    rank 8.0
    association :parent, :factory => :entity
    component
    user
  end
  
  factory :english_language do
    name "english"
  end

  factory :french_language do
    name "french"
  end

  factory :name do
    value "Some name"
    possible_name_spellings
    entity
    language
  end
  
  factory :possible_name_spelling do
    spelling "Some name"
    name
  end

end
