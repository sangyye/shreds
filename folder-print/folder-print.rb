#       folder-print.rb
#       
#       Copyright 2011 Christian Vervoorts <cvervoorts at gmail dot com>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

require 'rb-inotify'

notifier = INotify::Notifier.new

#mask the spaces for the system call
path = ARGV[0].gsub(/\s/, '\ ')

notifier.watch(ARGV[0], :moved_to, :create) do |event|
	next if event.name[0] == "." #do not print dot-files
	file = event.name.gsub(/\s/, '\ ')
	# get the mimetype with file, I do not know a good lib to use instead.
	mimetype = `file -b --mime-type #{path}/#{file}`.strip 
	if mimetype.include? "vnd.oasis.opendocument"
		puts "Print: #{file}!"
		#print all openoffice docs with the soffice command
		system("soffice -P #{path}/#{file}")
	elsif mimetype.include? "application/pdf"
		puts "Print: #{file}!"
		#you can print pdf directly with lpr
		system("lpr #{path}/#{file}")
	else
		puts "#{file} from type #{mimetype} not known!"
	end
end

notifier.run

