FactoryGirl.define do
  factory :ieducar_api_exam_posting do
    association :ieducar_api_configuration
    association :school_calendar_step
    association :author, factory: :user
    association :worker_batch, factory: :worker_batch
  end
end
