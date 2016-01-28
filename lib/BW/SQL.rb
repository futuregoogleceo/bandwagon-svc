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

        def get_all(sql, *params)
            rows = []
            res  = @conn.exec_params(sql, params)
            res.each do |tuple|
                rows.push(tuple)
            end
            return rows
        end

        def get_1value(sql, *params)
            res = @conn.exec_params(sql, params)
            return res.ntuples > 0 ? res.getvalue(0,0) : nil
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
end
