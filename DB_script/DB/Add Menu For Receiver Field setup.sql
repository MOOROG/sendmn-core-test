EXEC proc_addMenu '20', '10112200', 'Receive Page Field Setup',
    'Menu for: Receive Page Field Setup',
    '/SwiftSystem/ReceivePageFieldSetup/FieldSetup.aspx', 'Administration',
    '1', 'Y', '20', '';
EXEC proc_AddFunction '10112200', '10112200', 'View';	
EXEC proc_AddFunction '10112210', '10112200', 'Add/Edit';
EXEC proc_AddFunction '10112220', '10112200', 'Delete';