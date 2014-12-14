# Script to import the data from the Food_Display_Table.xml file with Raw Food data from Data.gov.
# This script utilizes the SAX parsing style utilized in the Wikipedia data import script created
# in the chapter.

import 'org.apache.hadoop.hbase.client.HTable'
import 'org.apache.hadoop.hbase.client.Put'
import 'javax.xml.stream.XMLStreamConstants'

def jbytes( *args )
  args.map { |arg| arg.to_s.to_java_bytes }
end

factory = javax.xml.stream.XMLInputFactory.newInstance
reader = factory.createXMLStreamReader(java.lang.System.in) # We will read from stdin

document = nil
buffer = nil
count = 0

table = HTable.new( @hbase.configuration, 'foods' )
table.setAutoFlush( false )

while reader.has_next
  type = reader.next
  if type == XMLStreamConstants::START_ELEMENT
    case reader.local_name
    when 'Food_Display_Row' then document = {} # Start a new document for the new food entry
    else buffer = []                           # Clear the buffer to hold the new nested element
    end
  elsif type == XMLStreamConstants::CHARACTERS
    buffer << reader.text unless buffer.nil?   # Store the data element
  elsif type == XMLStreamConstants::END_ELEMENT
    case reader.local_name
    when 'Food_Display_Row'                    
      # This is the end tag for the current food entry, so store it.
      key = document['Display_Name'].to_java_bytes # Utilize the food name for the key
      document.delete['Display_Name']

      # Create the data structure to store the data 
      p = Put.new( key )
      document.each do | label, fact |
        # For each element within the <Food_Display_Row> tags, add as a column-family to the 
        # 'facts' column.
        p.add( *jbytes('facts', label, fact ) )
      end
      table.put( p )

      count += 1
      table.flushCommits() if count % 10 == 0
      if count % 500 == 0
        puts "#{count} records inserted #{document['title']}"
      end
    else 
      # This is the end of the nested element.  Store it within
      # the document hash for later insertion into the db once all
      # nested elements for the current <Food_Display_Row> have been parsed.
      document[reader.local_name] = buffer.join 
    end
  end
end

table.flushCommits()
exit
