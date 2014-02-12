class Tag

  attr_reader :id
  attr_accessor :body

  def initialize(options={})
    @id, @body = options.values_at('id', 'body')
  end

  def most_popular_questions(n)
    questions = []

    query = <<-SQL
    SELECT
      questions.id, questions.author_id, questions.title, questions.body
    FROM
      questions
    JOIN
      question_tags
    ON
      questions.id = question_tags.question_id
    JOIN
      question_likes
    ON
      questions.id = question_likes.question_id
    WHERE
      tag_id = ?
    GROUP BY
      questions.id
    ORDER BY
      COUNT(*) DESC
    LIMIT ?
    SQL

    raw_questions = QuestionsDatabase.instance.execute(query, @id, n)
    raw_questions.each do |entry|
      questions << Question.new(entry)
    end
    questions
  end

  def self.most_popular(n)
    tags = []

    query = <<-SQL
    SELECT
      tags.id, tags.body
    FROM
      tags
    JOIN
      question_tags
    ON
      tags.id = question_tags.tag_id
    JOIN
      questions
    ON
      questions.id = question_tags.question_id
    JOIN
      question_likes
    ON
      questions.id = question_likes.question_id
    GROUP BY
      tags.id
    ORDER BY
      COUNT(*) DESC
    LIMIT ?
    SQL

    raw_tags = QuestionsDatabase.instance.execute(query, n)
    raw_tags.each do |entry|
      tags << Tag.new(entry)
    end
    tags
  end
end