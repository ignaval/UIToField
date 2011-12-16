<h1>UIToField</h1>

<p>UIToField is a complete re write of Joe Michels' <a href="http://www.softwareops.com/blogs/iPhone/iPhoneDevBlog_files/de891167adf425b139ddc1c27564b83b-44.html">Multi Recipient Picker Control </a>. I enhanced it to further mimic Apple's To: field, made it easier to include in exisiting projects, and provided easier ways to implement your own data source for the field.</p>

<p>Matt Gallagher's <a href="http://cocoawithlove.com/2009/08/adding-shadow-effects-to-uitableview.html">ShadowedTableView</a> is also used in this project.</p>

<h2>How to add UIToField to your project</h2>

<p>1. Copy all the files from the UIToFieldSupport folder o your project.</p>
<p>2. Import RecipientController.h in your view controller's .h file</p>
<p>3. Create the instance variable and property for the recipientController in your view controller's .h file</p>
<p>4. @synthesize the property in your .m file</p>
<p>5. Release the variable in your dealloc method</p>
<p>6. Create your data model object by implementig the DataMModelDelegate protocol (examples in ArrayDataModel and CoreDataModel)</p>
<p>6. Add the reciepientController's view in your viewDidLoad method, setting the model variable accordingly (with your own data model)</p>
<p>8. Resign first responder for the recipientController's entry field where appropriate (in the example I release it in the view controller's touchesBegan method)</p>
<p>9. Retrieve the added recipients where appropriate (in the example I retrieve them in the showRecipients method)</p>
<p>10. Enjoy UIToField!</p>