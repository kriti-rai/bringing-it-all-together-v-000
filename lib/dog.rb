require 'pry'
class Dog
  attr_accessor :id, :name, :breed
  # ATTRIBUTES = {
  #   :id => "INTEGER PRIMARY KEY",
  #   :name => "TEXT",
  #   :breed => "TEXT"
  # }
  # ATTRIBUTES.keys.each do |key|
  #   attr_accessor key
  # end

  def initialize(hash)
    hash.each {|k,v| self.send("#{k}=", v)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
      DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(array)
    hash = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    self.new(hash)
  end

  def insert
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)

    self
  end

  def save
    if !!self.id
      self.update
    else
      self.insert
    end
  end

  def self.create(hash)
    self.new(hash)
    self.save
  end



end
