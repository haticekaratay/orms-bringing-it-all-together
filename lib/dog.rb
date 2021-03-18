class Dog
    attr_accessor :name, :breed , :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end


    def save
        if self.id
            self.update
        else
            sql = <<-SQL
             INSERT INTO dogs (name, breed)
            VALUES(?,?)
            SQL
            data = DB[:conn].execute(sql,self.name,self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name:name, breed:breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
    new_dog = Dog.new(id:row[0], name:row[1],breed:row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE id = ?
        SQL
        data = DB[:conn].execute(sql,id)[0]
        self.new_from_db(data)
    end   

    
    def self.find_or_create_by(name:, breed:)
       data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)
       new_dog = nil
       if  !data.empty?
           dog_data = data[0]
           #self.new_from_db(dog_data[0])
           new_dog = Dog.new(id: dog_data[0],name:dog_data[1], breed:dog_data[2]) 
       else
          new_dog = self.create(name: name , breed: breed)
       end
       new_dog
    end

    def self.find_by_name(name)
        data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? ",name)
        new_from_db(data[0])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ? "
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end