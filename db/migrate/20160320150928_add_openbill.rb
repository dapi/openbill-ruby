class AddOpenbill < ActiveRecord::Migration
  def up
    Dir.entries(sql_dir).select{|f| File.file? sql_dir + f }.sort.each do |file|
      say_with_time "Migrate with #{file}" do
        execute File.read sql_dir + file
      end
    end
  end

  def down
    execute "DROP TABLE openbill_accounts CASCADE"
    execute "DROP TABLE openbill_transactions CASCADE"
  end

  private

  def sql_dir
    Openbill.root + '/sql/'
  end
end
