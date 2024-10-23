require 'json'

# Load the JSON data from specified files
def load_data
  begin
    companies_file = File.read('./companies.json')
    users_file = File.read('./users.json')
  rescue Errno::ENOENT => e
    puts "Error reading file: #{e.message}"
    exit
  end

  begin
    [JSON.parse(companies_file), JSON.parse(users_file)]
  rescue JSON::ParserError => e
    puts "Error parsing JSON: #{e.message}"
    exit
  end
end


# Format the output for an active user
# @param user [Hash] user data
# @param new_token [Integer] the user's new token balance
# @return [String] formatted user output
def format_user_output(user, new_token)
  <<~OUTPUT
    \t#{user['last_name']}, #{user['first_name']}, #{user['email']}
      Previous Token Balance: #{user['tokens']}
      New Token Balance: #{new_token}
  OUTPUT
end


# Generate the output for each company
# @param company [Hash] company data
# @param users [Array] array of user data
# @return [String] formatted company output
def generate_company_output(company, users)
  output = []
  output << "Company Id: #{company['id']}"
  output << "Company Name: #{company['name']}"
  output << "Users Emailed:"

  
  # Initialize the total top-ups for a company
  total_topups = 0  

  users.each do |user|
    next unless user['company_id'] == company['id'] && user['active_status'] == true

    new_token = user['tokens'] + company['top_up']

    if user['email_status'] == true && company['email_status'] == true
      output << format_user_output(user, new_token)
    else
      output << "Users Not Emailed:"
      output << format_user_output(user, user['tokens'] + company['top_up'])
    end
    total_topups += new_token - user['tokens']
  end

  output << "Total amount of top ups for #{company['name']}: #{total_topups}\n\n"

  # Combine the output into a single string
  output.join("\n")  
end



# Main logic
def main
  companies, users = load_data
  output_data = ""

  companies.each do |company|
    output_data << generate_company_output(company, users)
  end

  # Write the output data to an output.txt file
  File.write('./output.txt', output_data)

  puts "output result successfully created"
end

main
