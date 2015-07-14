# encoding: utf-8
require 'rails_helper'

RSpec.describe SchoolCalendar, type: :model do
  describe "attributes" do
    it { expect(subject).to respond_to(:year) }
    it { expect(subject).to respond_to(:number_of_classes) }
    it { expect(subject).to respond_to(:maximum_score) }
    it { expect(subject).to respond_to(:number_of_decimal_places) }
  end

  describe "associations" do
    it { expect(subject).to have_many(:steps) }
    it { expect(subject).to have_many(:events) }
  end

  describe "validations" do
    it { expect(subject).to validate_presence_of(:year) }
    it { expect(subject).to validate_uniqueness_of(:year) }
    it { expect(subject).to validate_presence_of(:number_of_classes) }
    it { expect(subject).to validate_numericality_of(:maximum_score).only_integer
                                                                    .is_greater_than_or_equal_to(1)
                                                                    .is_less_than_or_equal_to(1000) }
    it { expect(subject).to validate_numericality_of(:number_of_decimal_places).only_integer
                                                                               .is_greater_than_or_equal_to(0)
                                                                               .is_less_than_or_equal_to(3) }

    it "validates at least one assigned step" do
      subject.steps = []

      expect(subject).to_not be_valid
      expect(subject.errors.messages[:steps]).to include('É necessário adicionar pelo menos uma etapa')
    end
  end

  describe "#initialize" do
    before { subject = SchoolCalendar.new }

    it { expect(subject.maximum_score).to eq(10) }
    it { expect(subject.number_of_decimal_places).to eq(2) }
  end

  describe "#school_day?" do
    before do
      subject.attributes = { year: 2020, number_of_classes: 5, maximum_score: 10, number_of_decimal_places: 2 }
      subject.steps.build(start_at: '2020-02-15', end_at: '2020-05-01')
      subject.save!
      subject.events.create(event_date: '2020-04-25', description: 'Dia extra letivo', event_type: EventTypes::EXTRA_SCHOOL)
    end

    context "when the date is school day with a holiday event" do
      it "returns false" do
        date = '2020-04-21'.to_date
        expect(subject.school_day?(date)).to eq(false)
      end
    end

    context "when the date is a weekend day" do
      it "returns false" do
        date = '2020-05-03'.to_date
        expect(subject.school_day?(date)).to eq(false)
      end
    end

   context "when the date is a weekend day with extra school event" do
     it "returns true" do
       date = '2020-04-25'.to_date
       expect(subject.school_day?(date)).to eq(true)
     end
   end

   context "when the date is school day without a holiday event" do
     it "returns true" do
       date = '2020-04-20'.to_date
       expect(subject.school_day?(date)).to eq(true)
     end
   end
  end
end