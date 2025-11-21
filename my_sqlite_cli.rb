require "readline"
require_relative "my_sqlite_request"

class MySqliteRequestCli

  # ================================================================
  # MAIN LOOP
  # ================================================================
  def run!
    puts "Welcome to MySQLite! Type SQL or 'quit' to exit."

    while buf = Readline.readline("my_sqlite> ", true)
      break if buf.nil? || buf.strip.downcase == "quit"

      begin
        request = parse(buf)
        result  = request.run

        # Pretty-print the result
        if result.is_a?(Array)
          result.each { |row| p row }
        else
          p result
        end

      rescue => e
        puts "Error: #{e.message}"
      end
    end
  end


  # ================================================================
  # PARSER ENTRY POINT
  # ================================================================
  def parse(sql)
    sql = sql.strip.gsub(";", "")
    tokens = sql.split(/\s+/)

    command = tokens.shift.upcase

    case command
    when "SELECT"
      parse_select(tokens)

    when "INSERT"
      parse_insert(tokens)

    when "UPDATE"
      parse_update(tokens)

    when "DELETE"
      parse_delete(tokens)

    else
      raise "Unknown SQL command: #{command}"
    end
  end


  # ================================================================
  # SELECT
  # ================================================================
  def parse_select(tokens)
    # Collect column names until FROM
    select_columns = []
    while tokens.first && tokens.first.upcase != "FROM"
      col = tokens.shift.gsub(",", "")
      select_columns << col unless col.empty?
    end

    tokens.shift   # FROM
    table_name = tokens.shift

    req = MySqliteRequest.new
    req.from(table_name)
    req.select(*select_columns)

    while tokens.any?
      token = tokens.shift.upcase

      case token
      # when "JOIN"
      #   col_a = tokens.shift
      #   filename_b = tokens.shift
      #   col_b = tokens.shift
      #   req.join(col_a, filename_b, col_b)
      when "JOIN"
        table_b = tokens.shift               # ex: "teams"

        on_keyword = tokens.shift.upcase     # should be "ON"
        raise "Syntax error: expected ON" unless on_keyword == "ON"

        left_col = tokens.shift              # "nba_player.team_id"
        tokens.shift                         # "="
        right_col = tokens.shift             # "teams.team_id"

        req.join(left_col, table_b, right_col)

      when "WHERE"
        col = tokens.shift
        tokens.shift # "="
        val = tokens.shift.gsub('"', '')
        req.where(col, val)

      when "ORDER"
        tokens.shift # BY
        col = tokens.shift
        direction = tokens.shift&.downcase&.to_sym || :asc
        req.order(direction, col)
      end
    end

    req
  end


  # ================================================================
  # INSERT
  # ================================================================
  # def parse_insert(tokens)
  #   tokens.shift # INTO
  #   table_name = tokens.shift

  #   # (name, year_start)
  #   cols = tokens.shift.gsub("(", "").gsub(")", "").split(",")

  #   tokens.shift # VALUES
  #   vals = tokens.shift.gsub("(", "").gsub(")", "").split(",")

  #   cols.map!(&:strip)
  #   vals.map! { |v| v.gsub('"', "").strip }

  #   attributes = cols.zip(vals).to_h

  #   req = MySqliteRequest.new
  #   req.insert(table_name)
  #   req.values(attributes)
  #   req
  # end
  
  def parse_insert(tokens)
    tokens.shift # INTO
    table_name = tokens.shift

    # ------------------------------
    # Parse column list (...)
    # ------------------------------
    col_str = ""
    if tokens.first.start_with?("(")
      # accumulate until ")"
      while (tok = tokens.shift)
        col_str << tok << " "
        break if tok.include?(")")
      end
    end

    cols = col_str
            .gsub("(", "")
            .gsub(")", "")
            .split(",")
            .map(&:strip)

    tokens.shift # VALUES

    # ------------------------------
    # Parse value list (...)
    # ------------------------------
    val_str = ""
    if tokens.first.start_with?("(")
      while (tok = tokens.shift)
        val_str << tok << " "
        break if tok.include?(")")
      end
    end

    vals = val_str
            .gsub("(", "")
            .gsub(")", "")
            .split(",")
            .map { |v| v.strip.gsub('"', "") }

    attributes = cols.zip(vals).to_h

    req = MySqliteRequest.new
    req.insert(table_name)
    req.values(attributes)
    req
  end
 


  # ================================================================
  # UPDATE
  # ================================================================
  def parse_update(tokens)
    table_name = tokens.shift

    req = MySqliteRequest.new
    req.update(table_name)

    tokens.shift # SET

    update_hash = {}

    # Collect assignments until WHERE
    while tokens.first && tokens.first.upcase != "WHERE"
      assignment = tokens.shift
      col, val = assignment.split("=")
      update_hash[col] = val.gsub('"', '')
    end

    req.set(update_hash)

    if tokens.first&.upcase == "WHERE"
      tokens.shift
      col = tokens.shift
      tokens.shift # "="
      val = tokens.shift.gsub('"', '')
      req.where(col, val)
    end

    req
  end


  # ================================================================
  # DELETE
  # ================================================================
  def parse_delete(tokens)
    tokens.shift # FROM
    table_name = tokens.shift

    req = MySqliteRequest.new
    req.delete(table_name)

    if tokens.first&.upcase == "WHERE"
      tokens.shift
      col = tokens.shift
      tokens.shift # "="
      val = tokens.shift.gsub('"', '')
      req.where(col, val)
    end

    req
  end
end


# ================================================================
# RUN CLI
# ================================================================
if __FILE__ == $0
  MySqliteRequestCli.new.run!
end
