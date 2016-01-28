require 'pg'
require 'BW/SQL'

module BW
    class BW::DB
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
