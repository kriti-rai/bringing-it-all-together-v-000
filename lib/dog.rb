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

  def self.new_from_db(row)
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
    dog = self.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]

    self.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    dog = self.new(hash)

    # sql = <<-SQL
    #   SELECT id FROM dogs
    #   WHERE name = ?, breed = ?
    # SQL
    # 
    # row = DB[:conn].execute(sql, dog.name, dog.breed)
    binding.pry

    if !!row
      self.find_by_id(dog.id)
    else
      self.create(hash)
    end
  end

end
