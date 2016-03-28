class AddOpenbill < ActiveRecord::Migration
  def up
    Dir.glob(sql_dir + '*.sql') do |file|
      execute File.read file
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
