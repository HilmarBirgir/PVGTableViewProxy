#Release 0.2.1

Reverted rendering method back to a synchronous one to fix unwanted animations on UITableView. 
Made sure that loadMore is called asyncronously to prevent regression with pagination.

# Relase 0.2.0

Replaces NSTimer runloop with dispatch async to fix
rendering of multiple sections.