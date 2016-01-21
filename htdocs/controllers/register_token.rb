require 'pg'
require './db.rb'

class RegisterTokenController < Sinatra::Base
    post '/' do
        params.each do |key, value|
            puts "#{key} => #{value}"
        end
        [:type, :idfv, :token].each do |p|
            raise "Missing required parameter #{p}" unless params[p]
        end
        
        if (!params[:email] and !params[:phone])
            raise "Missing presistent user identifier (phone or email)"
        end

        raise "Unknown device type" if (params[:type] =~ /iPhone|iPad/).nil?
        raise "Malformatted device token" if (params[:token] =~ /[0-9A-Za-z\/+]{32}=/).nil?
        raise "Malformatted IDFV" if (params[:idfv] =~ /[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}/).nil?
        raise "Malformatted email" if params[:email] and (params[:email] =~ /.*@.*\..*/).nil?
        raise "Malformatted phone number" if params[:phone] and (params[:phone] =~ /[0-9]+/).nil?
        params.each do |key, value|
            puts "#{key} => #{value}"
        end

        db = BW::DB.connect()
        res = nil
        if (params[:email])
            res = db.get_all('SELECT * FROM bw_user WHERE email = $1', [params[:email]])
        else
            res = db.get_all('SELECT * FROM bw_user WHERE phone = $1', [params[:phone]])
        end

        uid = nil
        if (res.ntuples > 0)
            uid = res[0]['user_id']
            res = db.get_all('SELECT device_id, b64_device_token FROM bw_device WHERE idfv = $1', [params[:idfv]])

            if (res.ntuples > 0 and res[0]['b64_device_token'] != params[:token])
                db.update('bw_device', { 'b64_device_token' => params[:token] },
                    { 'device_id' => res[0]['device_id'] })
            elsif (res.ntuples == 0)
                db.insert('bw_device', {
                    'user_id' => uid,
                    'device_type' => params[:type],
                    'idfv' => params[:idfv],
                    'b64_device_token' => params[:token],
                });
            end
        else
            if (params[:email])
                db.insert('bw_user', { 'email' => params[:email] });
                res = db.get_all('SELECT user_id FROM bw_user WHERE email = $1', [params[:email]])
                uid = res[0]['user_id']
            else
                db.insert('bw_user', { 'phone' => params[:phone] });
                res = db.get_all('SELECT user_id FROM bw_user WHERE phone = $1', [params[:phone]])
                uid = res[0]['user_id']
            end

            db.insert('bw_device', {
                'user_id' => uid,
                'device_type' => params[:type],
                'idfv' => params[:idfv],
                'b64_device_token' => params[:token]
            });
        end

        puts "User id #{uid}"
    end
end
