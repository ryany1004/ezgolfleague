require 'rails_helper'

describe "Testing Course" do
  let(:course_with_holes) { FactoryBot.create(:course_with_holes) }

  it "Checking if a course has 18 holes" do
    expect(course_with_holes.course_holes.count).to eq(18)
  end
end
