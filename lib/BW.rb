module BW
    class BW::SQL
        @conn

        def initialize(db)
            @conn = PG::Connection.open(
                :host => db[:host],
                :user => db[:user],
                :password => db[:pass],
                :dbname => db[:dbname],
            )
        end

        def get_all(sql, params)
            return @conn.exec_params(sql, params)
        end

        def insert(table, to_insert = {})
            cols  = []
            vals  = []
            holds = []
            idx = 1

            to_insert.each do |key, val|
                cols.push(key)
                vals.push(val)
                holds.push("$#{idx}")
                idx += 1
            end

            sql = "INSERT INTO #{table} (#{cols.join(',')}) VALUES (#{holds.join(',')})"
            @conn.transaction do |conn|
                conn.exec_params(sql, vals)
            end
        end

        def update(table, to_update = {}, where = {})
            pairs = []
            conds = []
            vals  = []
            idx = 1

            to_update.each do |key, val|
                pairs.push("#{key}=$#{idx}")
                vals.push(val)
                idx += 1
            end

            where.each do |key, val|
                conds.push("#{key}=$#{idx}")
                vals.push(val)
                idx += 1
            end

            sql = "UPDATE #{table} SET #{pairs.join(',')} WHERE (#{conds.join(',')})"
            @conn.transaction do |conn|
                conn.exec_params(sql, vals)
            end
        end
    end


    class BW::DB
        require 'pg'

        @@connections = {}

        @@DB = {
            'prod' => {
                :user   => 'awsdbadmin',
                :pass   => 'b4ndw4g0n',
                :host   => 'sandboxdb2.cvfksdwegjkt.us-east-1.rds.amazonaws.com',
                :dbname => 'bandwagondb',
            },
        }

        def self.connect()
            return self._find_or_make_connection()
        end

        def self._find_or_make_connection(name = nil)
            name ||= 'prod'
            db = @@connections[name]
            return db if db

            db = self._connect(name)
            return db
        end

        def self._connect(name)
            db = @@DB[name]
            raise 'No available DB' unless db

            return BW::SQL.new(db)
        end
    end

end

