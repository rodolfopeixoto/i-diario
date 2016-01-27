class Discipline < ActiveRecord::Base
  acts_as_copy_target

  belongs_to :knowledge_area
  has_many :teacher_discipline_classrooms, dependent: :destroy

  validates :description, :api_code, :knowledge_area_id, presence: true
  validates :api_code, uniqueness: true

  scope :by_unity_id, lambda { |unity_id| by_unity_id(unity_id) }
  scope :by_teacher_id, lambda { |teacher_id| joins(:teacher_discipline_classrooms).where(teacher_discipline_classrooms: { teacher_id: teacher_id }).uniq }
  scope :by_grade, lambda { |grade| by_grade(grade) }
  scope :by_classroom, lambda { |classroom| by_classroom(classroom) }
  scope :by_teacher_and_classroom, lambda { |teacher_id, classroom_id| joins(:teacher_discipline_classrooms).where(teacher_discipline_classrooms: { teacher_id: teacher_id, classroom_id: classroom_id }).uniq }
  scope :ordered, -> { order(arel_table[:description].asc) }

  def to_s
    description
  end

  private

  def self.by_unity_id(unity_id)
    joins(:teacher_discipline_classrooms).joins(
        arel_table.join(Classroom.arel_table)
          .on(
            Classroom.arel_table[:id]
              .eq(TeacherDisciplineClassroom.arel_table[:classroom_id])
          )
          .join_sources
      )
      .where(classrooms: { unity_id: unity_id })
      .uniq
  end

  def self.by_grade(grade)
    joins(:teacher_discipline_classrooms).joins(
        arel_table.join(Classroom.arel_table)
          .on(
            Classroom.arel_table[:id]
              .eq(TeacherDisciplineClassroom.arel_table[:classroom_id])
          )
          .join_sources
      )
      .where(classrooms: { grade_id: grade })
      .uniq
  end

  def self.by_classroom(classroom)
    joins(:teacher_discipline_classrooms).where(
        teacher_discipline_classrooms: { classroom_id: classroom }
      )
      .uniq
  end
end
