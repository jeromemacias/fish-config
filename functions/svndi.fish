# Subversion
function svndi --description "SVN: Show diff with color."
	svn diff $argv | colordiff
end
