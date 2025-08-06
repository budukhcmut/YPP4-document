﻿USE MsList;
GO

INSERT INTO Account (FirstName, LastName, Email, AccountPassword, Avatar, Company, AccountStatus, DateBirth, CreatedAt, UpdatedAt)
SELECT TOP 1000
    'FirstName' + CAST(n AS NVARCHAR),
    'LastName' + CAST(n AS NVARCHAR),
    'user' + CAST(n AS NVARCHAR) + '@example.com', -- Unique email
    'password' + CAST(n AS NVARCHAR),
    'https://avatar.example.com/avatar' + CAST(n % 100 + 1 AS NVARCHAR) + '.png',
    'Company' + CAST(n % 10 + 1 AS NVARCHAR),
    CASE WHEN n <= 900 THEN 'Active' ELSE 'Inactive' END, -- 90% Active, 10% Inactive
    DATEADD(YEAR, -18 - (n % 43), '2025-07-29'), -- Birthdates from 18 to 60 years old
    DATEADD(DAY, n % 208, '2025-01-01'), -- CreatedAt from 2025-01-01 to ~2025-07-26
    GETDATE() AS UpdatedAt
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY a.object_id) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
) AS numbers
WHERE n BETWEEN 1 AND 1000;


INSERT INTO Workspace (WorkspaceName, CreatedAt, UpdatedAt)
SELECT TOP 1000
    'Workspace' + CAST(n AS NVARCHAR),
    DATEADD(DAY, n % 208, '2025-01-01'), -- CreatedAt from 2025-01-01 to ~2025-07-26
    GETDATE() AS UpdatedAt
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY a.object_id) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
) AS numbers
WHERE n BETWEEN 1 AND 1000;



INSERT INTO WorkspaceMember (WorkspaceId, AccountId, JoinedAt, MemberStatus, UpdatedAt)
SELECT 
    WorkspaceId,
    AccountId,
    DATEADD(DAY, (WorkspaceId + AccountId) % 208, '2025-01-01') AS JoinedAt, -- Dates from 2025-01-01 to ~2025-07-26
    CASE 
        WHEN (WorkspaceId + AccountId) % 20 < 18 THEN 'Active' -- 90% Active
        ELSE 'Inactive' -- 10% Inactive
    END AS MemberStatus,
    GETDATE() AS UpdatedAt
FROM (
    SELECT 
        w.Id AS WorkspaceId,
        a.Id AS AccountId
    FROM 
        (SELECT Id FROM Workspace WHERE Id BETWEEN 1 AND 200) w
        CROSS JOIN (SELECT Id FROM Account WHERE Id BETWEEN 1 AND 600) a
    WHERE 
        -- Distribute 5 Accounts per Workspace, ~1.67 Workspaces per Account
        ((a.Id - 1) / 120 + 1) = ((w.Id - 1) / 40 + 1) -- Divide into 5 groups
        AND (a.Id - 1) % 40 = (w.Id - 1) % 40 -- Round-robin assignment
) AS pairs
ORDER BY WorkspaceId, AccountId;


INSERT INTO Permission (PermissionName, PermissionCode, PermissionDescription, Icon)
VALUES 
    ('Administrator', 'Admin', 'Full access to manage and edit all resources', 'admin-icon.png'),
    ('Contributor', 'Contributor', 'Can edit and contribute to resources', 'contributor-icon.png'),
    ('Reader', 'Reader', 'Read-only access to view resources', 'reader-icon.png');


INSERT INTO ViewType (Title, HeaderImage, Icon, ViewTypeDescription)
VALUES 
    ('List', 'https://example.com/images/list.png', 'list-icon.png', 'Displays data in a tabular list format'),
    ('Gallery', 'https://example.com/images/gallery.png', 'gallery-icon.png', 'Shows data as a visual gallery'),
    ('Calendar', 'https://example.com/images/calendar.png', 'calendar-icon.png', 'Organizes data in a calendar view'),
    ('Board', 'https://example.com/images/board.png', 'board-icon.png', 'Presents data in a kanban board style');


INSERT INTO ListType (Title, Icon, ListTypeDescription, HeaderImage)
VALUES 
    ('List', 'list-icon.png', 'A tabular list for structured data display', 'https://example.com/images/list-header.png'),
    ('Form', 'form-icon.png', 'A form-based interface for data entry', 'https://example.com/images/form-header.png'),
    ('Gallery', 'gallery-icon.png', 'A visual gallery for image or card-based data', 'https://example.com/images/gallery-header.png'),
    ('Calendar', 'calendar-icon.png', 'A calendar view for date-based data', 'https://example.com/images/calendar-header.png'),
    ('Board', 'board-icon.png', 'A kanban board for task and workflow management', 'https://example.com/images/board-header.png');


INSERT INTO ViewSettingKey (SettingKey, ValueType)
VALUES 
    ('Set this as public view', 'BOOLEAN'),
    ('Start date on calendar', 'COLUMN'),
    ('End date on calendar', 'COLUMN'),
    ('Default layout', 'TEXT'),
    ('Title of items on calendar', 'COLUMN'),
    ('Subtitle', 'COLUMN'),
    ('Sort table by', 'COLUMN');


INSERT INTO ViewTypeSettingKey (ViewTypeId, ViewSettingKeyId)
VALUES 
    (1, 1), -- List view with "Set this as public view"
    (2, 1), -- Gallery view with "Set this as public view"
    (3, 1), -- Calendar view with "Set this as public view"
    (4, 1), -- Board view with "Set this as public view"
    (3, 2), -- Calendar view with "Start date on calendar"
    (3, 3), -- Calendar view with "End date on calendar"
    (3, 4), -- Calendar view with "Default layout"
    (3, 5), -- Calendar view with "Title of items on calendar"
    (3, 6), -- Calendar view with "Subtitle"
    (2, 7); -- Gallery view with "Sort table by"


INSERT INTO SystemDataType (DisplayName, DataTypeValue, Icon, DataTypeDescription, CoverImg)
VALUES 
    ('Single line of text', 'Text', 'text-icon.png', 'A single line of text for short entries', 'https://example.com/images/text-cover.png'),
    ('Multiple lines of text', 'Text', 'multiline-text-icon.png', 'Multiple lines of text for longer entries', 'https://example.com/images/multiline-text-cover.png'),
    ('Number', 'Number', 'number-icon.png', 'Numeric values for calculations or counts', 'https://example.com/images/number-cover.png'),
    ('Currency', 'Currency', 'currency-icon.png', 'Monetary values with currency format', 'https://example.com/images/currency-cover.png'),
    ('Date and time', 'DateTime', 'datetime-icon.png', 'Date and time values', 'https://example.com/images/datetime-cover.png'),
    ('Choice', 'Choice', 'choice-icon.png', 'Predefined options for selection', 'https://example.com/images/choice-cover.png'),
    ('Yes/No', 'Boolean', 'yesno-icon.png', 'Boolean values for yes or no choices', 'https://example.com/images/yesno-cover.png'),
    ('Lookup', 'Lookup', 'lookup-icon.png', 'Reference to data in another list', 'https://example.com/images/lookup-cover.png'),
    ('Person or Group', 'Person', 'person-icon.png', 'Select a person or group', 'https://example.com/images/person-cover.png'),
    ('Hyperlink', 'Text', 'hyperlink-icon.png', 'URL or web address', 'https://example.com/images/hyperlink-cover.png'),
    ('Picture', 'Text', 'picture-icon.png', 'Image or picture URL', 'https://example.com/images/picture-cover.png'),
    ('Location', 'Text', 'location-icon.png', 'Geographic location data', 'https://example.com/images/location-cover.png'),
    ('Rate', 'Number', 'rate-icon.png', 'Rating or scoring value', 'https://example.com/images/rate-cover.png');


INSERT INTO KeySetting (KeyName, ValueType, IsShareLinkSetting, IsDefaultValue, ValueOfDefault)
VALUES 
    ('Max length', 'number', 0, 1, '255'),
    ('Is required', 'boolean', 0, 1, 'FALSE'),
    ('Enforce unique values', 'boolean', 0, 1, 'FALSE'),
    ('Add to all content types', 'boolean', 0, 1, 'TRUE'),
    ('Choice setting', 'choice', 0, 0, NULL),
    ('Allow users to add custom values', 'boolean', 0, 1, 'FALSE'),
    ('Display type', 'text', 0, 0, NULL),
    ('Allow multiple choice', 'boolean', 0, 1, 'FALSE'),
    ('Default value', 'text', 0, 0, NULL),
    ('Default value', 'Choice', 0, 0, NULL),
    ('Include time', 'boolean', 0, 1, 'FALSE'),
    ('Default value', 'dateTime', 0, 0, NULL),
    ('Easy format to use', 'boolean', 0, 1, 'FALSE'),
    ('Use enhanced rich text', 'boolean', 0, 1, 'FALSE'),
    ('Append changes to existing text', 'boolean', 0, 1, 'FALSE'),
    ('Show avatar', 'boolean', 0, 1, 'FALSE'),
    ('Allow choose group', 'boolean', 0, 1, 'FALSE'),
    ('Number symbol', 'text', 0, 0, NULL),
    ('Number of decimal places', 'number', 0, 0, NULL),
    ('Default value', 'number', 0, 0, NULL),
    ('Minvalue allowed', 'number', 0, 0, NULL),
    ('Maxvalue allowed', 'number', 0, 0, NULL),
    ('Default value', 'boolean', 0, 1, 'FALSE'),
    ('Expiration date', 'dateTime', 1, 0, NULL),
    ('Password', 'text', 1, 0, NULL),
    ('Is login required', 'boolean', 1, 1, 'TRUE');


INSERT INTO DataTypeSettingKey (SystemDataTypeId, KeySettingId)
VALUES 
    (1, 1),  -- Single line of text - Max length
    (1, 2),  -- Single line of text - Is required
    (1, 3),  -- Single line of text - Enforce unique values
    (1, 4),  -- Single line of text - Add to all content types
    (1, 9),  -- Single line of text - Default value (text)
    (6, 5),  -- Choice - Choice setting
    (6, 6),  -- Choice - Allow users to add custom values
    (6, 7),  -- Choice - Display type
    (6, 8),  -- Choice - Allow multiple choice
    (6, 2),  -- Choice - Is required
    (6, 3),  -- Choice - Enforce unique values
    (6, 4),  -- Choice - Add to all content types
    (6, 10), -- Choice - Default value (Choice)
    (5, 11), -- Date and time - Include time
    (5, 12), -- Date and time - Default value (dateTime)
    (5, 13), -- Date and time - Easy format to use
    (5, 2),  -- Date and time - Is required
    (5, 3),  -- Date and time - Enforce unique values
    (5, 4),  -- Date and time - Add to all content types
    (2, 14), -- Multiple lines of text - Use enhanced rich text
    (2, 15), -- Multiple lines of text - Append changes to existing text
    (2, 2),  -- Multiple lines of text - Is required
    (2, 4),  -- Multiple lines of text - Add to all content types
    (9, 16), -- Person or Group - Show avatar
    (9, 17), -- Person or Group - Allow choose group
    (9, 2),  -- Person or Group - Is required
    (9, 3),  -- Person or Group - Enforce unique values
    (9, 4),  -- Person or Group - Add to all content types
    (3, 18), -- Number - Number symbol
    (3, 19), -- Number - Number of decimal places
    (3, 20), -- Number - Default value (number)
    (3, 21), -- Number - Minvalue allowed
    (3, 22), -- Number - Maxvalue allowed
    (3, 2),  -- Number - Is required
    (3, 3),  -- Number - Enforce unique values
    (3, 4),  -- Number - Add to all content types
    (7, 2),  -- Yes/No - Is required
    (7, 4),  -- Yes/No - Add to all content types
    (7, 23), -- Yes/No - Default value (boolean)
    (10, 2), -- Hyperlink - Is required
    (10, 4), -- Hyperlink - Add to all content types
    (11, 2), -- Picture - Is required
    (11, 4); -- Picture - Add to all content types


INSERT INTO TemplateProvider (ProviderName)
VALUES ('Microsoft');
-- Insert the remaining 999 records with repeating pattern
INSERT INTO TemplateProvider (ProviderName)
SELECT 
    'templateprovider_' + CAST((n % 3 + 2) AS NVARCHAR) -- Cycles through 2, 3, 4
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY a.object_id) - 1 AS n
    FROM sys.objects a CROSS JOIN sys.objects b
) AS numbers
WHERE n BETWEEN 0 AND 998; -- Generate 999 records to reach total 1000

INSERT INTO ListTemplate (Title, HeaderImage, TemplateDescription, Icon, Color, Sumary, Feature, ProviderId)
VALUES 
    ('Asset Manager', 'https://example.com/templates/asset-manager-header.png', 'The Asset Manager template helps track physical assets used by your team, knowing who holds which asset, which assets are under repair, and the check-in/check-out dates.', 'asset-manager-icon.png', 'blue', 'Track physical assets', 'Manage check-in/check-out, repair status, asset allocation', 1),
    ('Content Scheduler', 'https://example.com/templates/content-scheduler-header.png', 'The Content Scheduler template helps plan and manage content strategy. Filter upcoming due items or get notifications when authors submit drafts.', 'content-scheduler-icon.png', 'green', 'Plan content', 'Manage content strategy, filter due items, notifications', 1),
    ('Employee Onboarding', 'https://example.com/templates/employee-onboarding-header.png', 'The Employee Onboarding template helps manage the onboarding process for new employees and guide them through relevant contacts and resources.', 'employee-onboarding-icon.png', 'orange', 'Onboard new employees', 'Manage onboarding process, contacts, resources', 1),
    ('Event Itinerary', 'https://example.com/templates/event-itinerary-header.png', 'The Event Itinerary template organizes all important event details in one place, ensuring everything runs smoothly. Switch to calendar view for a clear view of event activities by time (day, week, month).', 'event-itinerary-icon.png', 'purple', 'Organize events', 'Manage event details, calendar view', 1),
    ('Issue Tracker', 'https://example.com/templates/issue-tracker-header.png', 'The Issue Tracker template helps track, manage, and resolve issues by easily setting priority levels in the status column and notifying team members when issues arise.', 'issue-tracker-icon.png', 'red', 'Track issues', 'Manage issues, set priorities, notifications', 1),
    ('Recruitment Tracker', 'https://example.com/templates/recruitment-tracker-header.png', 'The Recruitment Tracker template helps track and manage the hiring process within your organization or team, capturing feedback for all candidates.', 'recruitment-tracker-icon.png', 'yellow', 'Manage hiring', 'Track hiring process, candidate feedback', 1),
    ('Travel Requests', 'https://example.com/templates/travel-requests-header.png', 'The Travel Requests template helps manage all travel requests and track budgets.', 'travel-requests-icon.png', 'teal', 'Manage travel requests', 'Track travel requests, budgets', 1),
    ('Work Tracker', 'https://example.com/templates/work-tracker-header.png', 'The Work Tracker template helps track priorities and progress as you work to deliver products and services.', 'work-tracker-icon.png', 'gray', 'Track work progress', 'Manage work priorities, progress', 1),
    ('Incidents', 'https://example.com/templates/incidents-header.png', 'The Incidents template helps track and manage incidents, such as IT issues or security breaches, with status updates and notifications.', 'incidents-icon.png', 'pink', 'Track incidents', 'Manage incidents, status updates, notifications', 1),
    ('Patients', 'https://example.com/templates/patients-header.png', 'The Patients template helps healthcare staff track patient information, including medical history, appointments, and treatment plans.', 'patients-icon.png', 'brown', 'Track patient information', 'Manage medical history, appointments, treatment plans', 1),
    ('Loans', 'https://example.com/templates/loans-header.png', 'The Loans template helps manage loan applications, approvals, and repayments, tracking all loan-related information.', 'loans-icon.png', 'black', 'Manage loans', 'Track loan applications, approvals, repayments', 1),
    ('Task Planner', 'https://example.com/templates/task-planner-header.png', 'The Task Planner template helps organize and prioritize tasks for team projects, with options to assign tasks and track completion.', 'task-planner-icon.png', 'cyan', 'Plan tasks', 'Organize tasks, assign team members, track completion', 1),
    ('Inventory Management', 'https://example.com/templates/inventory-management-header.png', 'The Inventory Management template helps track stock levels, reorder points, and supplier details for efficient inventory control.', 'inventory-management-icon.png', 'lime', 'Manage inventory', 'Track stock levels, reorder points, supplier details', 1),
    ('Feedback Collector', 'https://example.com/templates/feedback-collector-header.png', 'The Feedback Collector template helps gather and organize feedback from customers or team members, with options to categorize and prioritize responses.', 'feedback-collector-icon.png', 'magenta', 'Collect feedback', 'Gather feedback, categorize responses, prioritize actions', 1);


INSERT INTO ListTemplate (Title, HeaderImage, TemplateDescription, Icon, Color, Sumary, Feature, ProviderId)
SELECT 
    'template' + CAST(p.Id AS NVARCHAR) + '_' + CAST(n AS NVARCHAR) AS Title,
    'https://example.com/templates/template' + CAST(p.Id AS NVARCHAR) + '_' + CAST(n AS NVARCHAR) + '-header.png' AS HeaderImage,
    'Description for template ' + CAST(p.Id AS NVARCHAR) + '_' + CAST(n AS NVARCHAR) + ' provided by provider ' + CAST(p.Id AS NVARCHAR) AS TemplateDescription,
    'template' + CAST(p.Id AS NVARCHAR) + '_' + CAST(n AS NVARCHAR) + '-icon.png' AS Icon,
    CASE 
        WHEN n = 1 THEN 'blue'
        WHEN n = 2 THEN 'green'
        WHEN n = 3 THEN 'orange'
    END AS Color,
    'Summary for template ' + CAST(p.Id AS NVARCHAR) + '_' + CAST(n AS NVARCHAR) AS Sumary,
    'Feature for template ' + CAST(p.Id AS NVARCHAR) + '_' + CAST(n AS NVARCHAR) AS Feature,
    p.Id AS ProviderId
FROM 
    TemplateProvider p
CROSS JOIN 
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) AS numbers
WHERE 
    p.Id BETWEEN 2 AND 200;


INSERT INTO TemplateView (ListTemplateId, ViewTypeId, ViewName, DisplayOrder)
SELECT 
    lt.Id AS ListTemplateId,
    vt.Id AS ViewTypeId,
    lt.Title + ' ' + vt.Title AS ViewName,
    vt.Id AS DisplayOrder
FROM 
    ListTemplate lt
CROSS JOIN 
    ViewType vt
WHERE 
    lt.Id BETWEEN 1 AND 100
    AND vt.Id IN (1, 2, 4)
ORDER BY 
    lt.Id, vt.Id;


INSERT INTO TemplateColumn (SystemDataTypeId, ListTemplateId, ColumnName, ColumnDescription, DisplayOrder, IsVisible)
SELECT 
    CASE n
        WHEN 1 THEN 1  -- Text
        WHEN 2 THEN 3  -- Number
        WHEN 3 THEN 5  -- DateTime
        WHEN 4 THEN 6  -- Choice
        WHEN 5 THEN 11 -- Picture
    END AS SystemDataTypeId,
    lt.Id AS ListTemplateId,
    lt.Title + ' col ' + CAST(n AS NVARCHAR) AS ColumnName,
    CASE 
        WHEN n = 1 THEN 'Text column for ' + lt.Title + ' col ' + CAST(n AS NVARCHAR)
        WHEN n = 2 THEN 'Number column for ' + lt.Title + ' col ' + CAST(n AS NVARCHAR)
        WHEN n = 3 THEN 'DateTime column for ' + lt.Title + ' col ' + CAST(n AS NVARCHAR)
        WHEN n = 4 THEN 'Choice column for ' + lt.Title + ' col ' + CAST(n AS NVARCHAR)
        WHEN n = 5 THEN 'Picture column for ' + lt.Title + ' col ' + CAST(n AS NVARCHAR)
    END AS ColumnDescription,
    n AS DisplayOrder,
    1 AS IsVisible
FROM 
    ListTemplate lt
CROSS JOIN 
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) AS numbers
WHERE 
    lt.Id BETWEEN 1 AND 100
ORDER BY 
    lt.Id, n;


INSERT INTO TemplateColumnSettingValue (TemplateColumnId, DataTypeSettingKeyId, KeyValue)
SELECT 
    tc.Id AS TemplateColumnId,
    dtsk.Id AS DataTypeSettingKeyId,
    CASE 
        -- Single line of text (SystemDataTypeId = 1)
        WHEN dtsk.KeySettingId = 1 THEN CAST(tc.Id * 100 AS NVARCHAR) -- Max length = TemplateColumn.Id * 100
        WHEN dtsk.KeySettingId = 9 THEN LEFT(tc.ColumnName, 4) -- Default value = first 4 chars of ColumnName
        -- Number (SystemDataTypeId = 3)
        WHEN dtsk.KeySettingId = 19 THEN 
            CASE 
                WHEN tc.Id % 2 = 1 THEN '1' -- Odd Id: 1 decimal place
                ELSE '2' -- Even Id: 2 decimal places
            END
        -- DateTime (SystemDataTypeId = 5)
        WHEN dtsk.KeySettingId = 12 THEN 
            CASE 
                WHEN tc.Id % 2 = 1 THEN '2025-08-01' -- Odd Id
                ELSE '2025-08-02' -- Even Id
            END
        -- Apply ValueOfDefault if IsDefaultValue = true
        WHEN ks.IsDefaultValue = 1 THEN ks.ValueOfDefault
        -- Other settings: NULL
        ELSE NULL
    END AS KeyValue
FROM 
    TemplateColumn tc
JOIN 
    DataTypeSettingKey dtsk ON tc.SystemDataTypeId = dtsk.SystemDataTypeId
JOIN 
    KeySetting ks ON dtsk.KeySettingId = ks.Id
WHERE 
    tc.Id BETWEEN 1 AND 70
    AND dtsk.Id IN (
        1, 2, 3, 4, 5,  -- Text (Single line of text)
        6, 7, 8, 9, 10, 11, 12, 13, -- Choice
        14, 15, 16, 17, 18, 19, -- DateTime
        29, 30, 31, 32, 33, 34, 35, 36, -- Number
        42, 43 -- Picture
    )
ORDER BY 
    tc.Id, dtsk.Id;


INSERT INTO ColumnSettingObject (ColumnId, DisplayName, DisplayColor, DisplayOrder, Context, CreatedAt, UpdatedAt)
SELECT 
    tc.Id AS ColumnId,
    tc.ColumnName + ' choice ' + CAST(n AS NVARCHAR) AS DisplayName,
    CASE 
        WHEN n = 1 THEN 'blue'
        WHEN n = 2 THEN 'green'
        WHEN n = 3 THEN 'orange'
    END AS DisplayColor,
    n AS DisplayOrder,
    'TEMPLATE' AS Context,
    GETDATE() AS CreatedAt,
    GETDATE() AS UpdatedAt
FROM 
    TemplateColumn tc
CROSS JOIN 
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) AS numbers
WHERE 
    tc.ListTemplateId BETWEEN 1 AND 14
    AND tc.SystemDataTypeId = 6
ORDER BY 
    tc.Id, n;


INSERT INTO TemplateViewSettingValue (TemplateViewId, ViewTypeSettingId, GroupByColumnId, RawValue)
SELECT 
    tv.Id AS TemplateViewId,
    vtsk.Id AS ViewTypeSettingId,
    CASE 
        WHEN vtsk.Id = 7 THEN 
            (SELECT Id FROM TemplateColumn tc 
             WHERE tc.ListTemplateId = tv.ListTemplateId 
             AND tc.SystemDataTypeId = 6)
        ELSE NULL
    END AS GroupByColumnId,
    CASE 
        WHEN vtsk.Id = 1 THEN 'true'
        ELSE NULL
    END AS RawValue
FROM 
    TemplateView tv
CROSS JOIN 
    (SELECT Id FROM ViewTypeSettingKey WHERE Id IN (1, 7)) vtsk
WHERE 
    tv.ListTemplateId BETWEEN 1 AND 14
    AND (
        vtsk.Id = 1 -- Applies to all view types (List, Gallery, Board)
        OR (vtsk.Id = 7 AND tv.ViewTypeId = 4) -- Sort table by applies only to Board view
    )
ORDER BY 
    tv.Id, vtsk.Id;


INSERT INTO TemplateSampleRow (ListTemplateId, DisplayOrder)
SELECT 
    lt.Id AS ListTemplateId,
    n AS DisplayOrder
FROM 
    (SELECT Id FROM ListTemplate WHERE Id BETWEEN 1 AND 14) lt
CROSS JOIN 
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) numbers
ORDER BY 
    lt.Id, n;


INSERT INTO TemplateSampleCell (TemplateColumnId, TemplateSampleRowId, CellValue)
SELECT 
    tc.Id AS TemplateColumnId,
    tsr.Id AS TemplateSampleRowId,
    CASE 
        -- Text (SystemDataTypeId = 1)
        WHEN tc.SystemDataTypeId = 1 THEN 
            CASE 
                WHEN LEN(tc.ColumnName) >= tc.Id * 100 THEN LEFT(tc.ColumnName, tc.Id * 100) -- Respect Max length
                ELSE 'Row' + CAST(tsr.DisplayOrder AS NVARCHAR) + '_' + tc.ColumnName -- Fallback if Max length too long
            END
        -- Number (SystemDataTypeId = 3)
        WHEN tc.SystemDataTypeId = 3 THEN 
            CASE 
                WHEN tc.Id % 2 = 1 THEN 
                    CAST(CAST(100 + (tsr.DisplayOrder * 50) AS DECIMAL(6,1)) AS NVARCHAR) -- 1 decimal place for odd Id
                ELSE 
                    CAST(CAST(100 + (tsr.DisplayOrder * 50) AS DECIMAL(6,2)) AS NVARCHAR) -- 2 decimal places for even Id
            END
        -- DateTime (SystemDataTypeId = 5)
        WHEN tc.SystemDataTypeId = 5 THEN 
            CASE 
                WHEN tc.Id % 2 = 1 THEN '2025-08-01' -- Odd Id
                ELSE '2025-08-02' -- Even Id
            END
        -- Choice (SystemDataTypeId = 6)
        WHEN tc.SystemDataTypeId = 6 THEN 
            CAST((
                SELECT cso.Id 
                FROM ColumnSettingObject cso 
                WHERE cso.ColumnId = tc.Id 
                AND cso.DisplayOrder = ((tsr.DisplayOrder - 1) % 3 + 1)
            ) AS NVARCHAR) -- Use ColumnSettingObject.Id
        -- Picture (SystemDataTypeId = 11)
        WHEN tc.SystemDataTypeId = 11 THEN 
            'https://example.com/images/sample' + CAST(tsr.DisplayOrder AS NVARCHAR) + '.jpg'
    END AS CellValue
FROM 
    TemplateColumn tc
JOIN 
    TemplateSampleRow tsr ON tc.ListTemplateId = tsr.ListTemplateId
WHERE 
    tc.Id BETWEEN 1 AND 70
ORDER BY 
    tsr.Id, tc.Id;


INSERT INTO List (ListName, Icon, Color, WorkspaceId, CreatedBy, CreatedAt, UpdatedAt, ListStatus)
SELECT 
    'User' + CAST(wm.AccountId AS NVARCHAR) + ' List ' + CAST(n AS NVARCHAR) AS ListName,
    CASE n
        WHEN 1 THEN 'list-icon.png'
        WHEN 2 THEN 'task-icon.png'
        WHEN 3 THEN 'project-icon.png'
    END AS Icon,
    CASE n
        WHEN 1 THEN 'blue'
        WHEN 2 THEN 'green'
        WHEN 3 THEN 'red'
    END AS Color,
    wm.WorkspaceId,
    wm.AccountId AS CreatedBy,
    '2025-08-03 17:18:00' AS CreatedAt,
    '2025-08-03 17:18:00' AS UpdatedAt,
    'Active' AS ListStatus
FROM 
    WorkspaceMember wm
CROSS JOIN 
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) numbers
WHERE 
    wm.MemberStatus = 'Active'
ORDER BY 
    wm.WorkspaceId, wm.AccountId, n;


INSERT INTO ListView (ListId, CreatedBy, ViewTypeId, ViewName, DisplayOrder, CreatedAt, UpdatedAt)
SELECT 
    l.Id AS ListId,
    l.CreatedBy,
    vt.Id AS ViewTypeId,
    vt.Title + ' ' + l.ListName AS ViewName,
    vt.Id AS DisplayOrder,
    '2025-08-03 18:01:00' AS CreatedAt,
    '2025-08-03 18:01:00' AS UpdatedAt
FROM 
    List l
CROSS JOIN 
    ViewType vt
WHERE 
    l.Id BETWEEN 1 AND 60
    AND vt.Id IN (1, 2, 3, 4)
ORDER BY 
    l.Id, vt.Id;


INSERT INTO SystemColumn (SystemDataTypeId, ColumnName, DisplayOrder, CreatedAt, CanRename)
VALUES 
    (1, 'Title', 1, '2025-08-03 18:49:00', 1),            -- Title column (Text, can be renamed)
    (3, 'AssetID', 2, '2025-08-03 18:49:00', 0),          -- Asset ID (Number, not renameable)
    (3, 'ID', 3, '2025-08-03 18:49:00', 0),               -- Unique ID (Number, not renameable)
    (5, 'CreatedDate', 4, '2025-08-03 18:49:00', 0),       -- Creation date (DateTime, not renameable)
    (5, 'ModifiedDate', 5, '2025-08-03 18:49:00', 0),      -- Last modified date (DateTime, not renameable)
    (9, 'CreatedBy', 6, '2025-08-03 18:49:00', 0),         -- Creator (Person, not renameable)
    (10, 'Attachments', 7, '2025-08-03 18:49:00', 0),      -- Attachments (Hyperlink, not renameable)
    (11, 'Type', 8, '2025-08-03 18:49:00', 0),             -- Type (Picture, not renameable)
    (3, 'ViewCount', 9, '2025-08-03 18:49:00', 0),         -- View count (Number, not renameable)
    (3, 'ChildCount', 10, '2025-08-03 18:49:00', 0),       -- Child count (Number, not renameable)
    (1, 'Labels', 11, '2025-08-03 18:49:00', 0),           -- Labels (Text, not renameable, purpose TBD)
    (9, 'AssignedTo', 12, '2025-08-03 18:49:00', 0),       -- Assigned to (Person, not renameable)
    (7, 'IsRecord', 13, '2025-08-03 18:49:00', 0);         -- Is record flag (Yes/No, not renameable)


INSERT INTO SystemColumnSettingValue (SystemColumnId, DataTypeSettingKeyId, KeyValue)
SELECT 
    sc.Id AS SystemColumnId,
    dtsk.Id AS DataTypeSettingKeyId,
    CASE 
        WHEN ks.IsDefaultValue = 1 THEN ks.ValueOfDefault
        ELSE NULL
    END AS KeyValue
FROM 
    SystemColumn sc
CROSS JOIN 
    DataTypeSettingKey dtsk
INNER JOIN 
    KeySetting ks ON dtsk.KeySettingId = ks.Id
WHERE 
    sc.Id BETWEEN 1 AND 13
    AND dtsk.SystemDataTypeId = sc.SystemDataTypeId
ORDER BY 
    sc.Id, dtsk.Id;


INSERT INTO ListDynamicColumn (ListId, SystemDataTypeId, SystemColumnId, ColumnName, ColumnDescription, DisplayOrder, IsSystemColumn, IsVisible, CreatedBy, CreatedAt, UpdatedAt)
SELECT 
    l.Id AS ListId,
    sc.SystemDataTypeId,
    sc.Id AS SystemColumnId,
    sc.ColumnName,
    'System column: ' + sc.ColumnName,
    sc.DisplayOrder + 7 AS DisplayOrder, -- Offset to prioritize custom columns
    1 AS IsSystemColumn,
    1 AS IsVisible,
    l.CreatedBy,
    '2025-08-03 19:29:00' AS CreatedAt,
    '2025-08-03 19:29:00' AS UpdatedAt
FROM 
    List l
CROSS JOIN 
    SystemColumn sc
WHERE 
    l.Id BETWEEN 1 AND 60
UNION
SELECT 
    l.Id AS ListId,
    CASE 
        WHEN c.ColumnName = 'itemname' THEN 1
        WHEN c.ColumnName = 'number' THEN 3
        WHEN c.ColumnName IN ('startdate', 'endDate') THEN 5
        WHEN c.ColumnName = 'itemchoice' THEN 6
        WHEN c.ColumnName = 'itemimage' THEN 11
        WHEN c.ColumnName = 'itemhyperlink' THEN 10
    END AS SystemDataTypeId,
    NULL AS SystemColumnId,
    c.ColumnName,
    'Custom column: ' + c.ColumnName,
    c.DisplayOrder,
    0 AS IsSystemColumn,
    1 AS IsVisible,
    l.CreatedBy,
    '2025-08-03 19:29:00' AS CreatedAt,
    '2025-08-03 19:29:00' AS UpdatedAt
FROM 
    List l
CROSS JOIN 
    (VALUES 
        (1, 'itemname'),
        (2, 'number'),
        (3, 'startdate'),
        (3, 'endDate'),
        (4, 'itemchoice'),
        (5, 'itemimage'),
        (6, 'itemhyperlink')
    ) c(DisplayOrder, ColumnName)
WHERE 
    l.Id BETWEEN 1 AND 60
ORDER BY 
    ListId, DisplayOrder;


INSERT INTO DynamicColumnSettingValue (DynamicColumnId, DataTypeSettingKeyId, KeyValue, CreatedAt, UpdatedAt)
SELECT 
    ldc.Id AS DynamicColumnId,
    dtsk.Id AS DataTypeSettingKeyId,
    CASE 
        -- Single line of text (itemname, SystemDataTypeId = 1)
        WHEN ldc.ColumnName = 'itemname' AND dtsk.KeySettingId = 1 THEN CAST(ldc.ListId * 100 AS NVARCHAR(255)) -- Max length = ListId * 100
        WHEN ldc.ColumnName = 'itemname' AND dtsk.KeySettingId = 9 THEN LEFT(ldc.ColumnName, 4) -- Default value = first 4 chars
        -- Number (number, SystemDataTypeId = 3)
        WHEN ldc.ColumnName = 'number' AND dtsk.KeySettingId = 19 THEN 
            CASE WHEN ldc.ListId % 2 = 1 THEN '1' ELSE '2' END -- Number of decimal places
        -- DateTime (startdate, endDate, SystemDataTypeId = 5)
        WHEN ldc.ColumnName IN ('startdate', 'endDate') AND dtsk.KeySettingId = 12 THEN 
            CASE WHEN ldc.ListId % 2 = 1 THEN '2025-08-10' ELSE '2025-08-20' END -- Default value
        -- Default value from KeySetting
        WHEN ks.IsDefaultValue = 1 THEN ks.ValueOfDefault
        ELSE NULL
    END AS KeyValue,
    '2025-08-03 19:43:00' AS CreatedAt,
    '2025-08-03 19:43:00' AS UpdatedAt
FROM 
    ListDynamicColumn ldc
CROSS JOIN 
    DataTypeSettingKey dtsk
LEFT JOIN 
    KeySetting ks ON dtsk.KeySettingId = ks.Id
WHERE 
    ldc.IsSystemColumn = 0 -- just apply for custom columns
    AND ldc.ListId BETWEEN 1 AND 60
    AND dtsk.SystemDataTypeId = ldc.SystemDataTypeId
ORDER BY 
    ldc.Id, dtsk.Id;


DECLARE @StartId INT = 5;
DECLARE @EndId INT = 1185;
DECLARE @CurrentId INT = @StartId;
DECLARE @ChoiceCount INT = 3;

WHILE @CurrentId <= @EndId
BEGIN
    INSERT INTO ColumnSettingObject (ColumnId, DisplayName, DisplayColor, DisplayOrder, Context, CreatedAt, UpdatedAt)
    SELECT 
        @CurrentId AS ColumnId,
        'itemchoice choice ' + CAST(n.Number AS NVARCHAR(10)) AS DisplayName,
        CASE (n.Number - 1) % 3 
            WHEN 0 THEN 'blue'
            WHEN 1 THEN 'green'
            WHEN 2 THEN 'orange'
        END AS DisplayColor,
        n.Number AS DisplayOrder,
        'LIST' AS Context,
        '2025-08-04 00:54:00' AS CreatedAt,
        '2025-08-04 00:54:00' AS UpdatedAt
    FROM master.dbo.spt_values n
    WHERE n.type = 'P'
    AND n.number BETWEEN 1 AND @ChoiceCount;

    SET @CurrentId = @CurrentId + 20;
END;

DECLARE @ListCount INT = 60;
DECLARE @RowsPerList INT = 5;
DECLARE @CurrentListId INT = 1;

WHILE @CurrentListId <= @ListCount
BEGIN
    DECLARE @CreatedBy INT = (SELECT TOP 1 CreatedBy FROM ListDynamicColumn WHERE ListId = @CurrentListId ORDER BY Id);

    DECLARE @RowCounter INT = 1;
    WHILE @RowCounter <= @RowsPerList
    BEGIN
        INSERT INTO ListRow (ListId, DisplayOrder, ModifiedAt, CreatedBy, ListRowStatus, CreatedAt, UpdatedAt)
        VALUES (@CurrentListId, @RowCounter, DATEADD(hour, @RowCounter, '2025-08-04 01:18:00'), @CreatedBy, 'Active', '2025-08-04 01:18:00', '2025-08-04 01:18:00');
        SET @RowCounter = @RowCounter + 1;
    END;

    SET @CurrentListId = @CurrentListId + 1;
END;


DECLARE @ListCount2 INT = 60;
DECLARE @RowsPerList2 INT = 5;
DECLARE @CurrentListId2 INT = 1;

WHILE @CurrentListId2 <= @ListCount2
BEGIN
    DECLARE @CreatedBy2 INT = (SELECT TOP 1 CreatedBy FROM ListRow WHERE ListId = @CurrentListId2 ORDER BY Id);

    DECLARE @RowCounter2 INT = 1;
    WHILE @RowCounter2 <= @RowsPerList2
    BEGIN
        DECLARE @CurrentRowId2 INT = (SELECT TOP 1 Id FROM ListRow WHERE ListId = @CurrentListId2 AND DisplayOrder = @RowCounter2 ORDER BY Id DESC);

        INSERT INTO ListCellValue (ListRowId, ListColumnId, CellValue, CreatedBy, CreatedAt, UpdatedAt)
        SELECT 
            @CurrentRowId2 AS ListRowId,
            c.Id AS ListColumnId,
            CASE 
                WHEN c.ColumnName = 'itemname' THEN 'Item ' + CAST(@CurrentListId2 AS NVARCHAR(10)) + '-' + CAST(@RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'number' THEN CAST((@CurrentListId2 * 10 + @RowCounter2) AS NVARCHAR(10))
                WHEN c.ColumnName = 'endDate' THEN CONVERT(NVARCHAR(50), DATEADD(day, @RowCounter2, '2025-08-04'), 120)
                WHEN c.ColumnName = 'startdate' THEN CONVERT(NVARCHAR(50), DATEADD(day, -@RowCounter2, '2025-08-04'), 120)
                WHEN c.ColumnName = 'itemchoice' THEN 
                    CAST((SELECT Id FROM ColumnSettingObject WHERE ColumnId = c.Id AND DisplayOrder = ((@RowCounter2 - 1) % 3 + 1) AND Context = 'LIST') AS NVARCHAR(10))
                WHEN c.ColumnName = 'itemimage' THEN 'image' + CAST(@CurrentListId2 AS NVARCHAR(10)) + '-' + CAST(@RowCounter2 AS NVARCHAR(10)) + '.jpg'
                WHEN c.ColumnName = 'itemhyperlink' THEN 'http://example.com/' + CAST(@CurrentListId2 AS NVARCHAR(10)) + '/' + CAST(@RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'Title' THEN 'Title ' + CAST(@CurrentListId2 AS NVARCHAR(10)) + '-' + CAST(@RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'AssetID' THEN CAST(@CurrentListId2 * 100 + @RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'ID' THEN CAST(@CurrentListId2 * 1000 + @RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'CreatedDate' THEN CONVERT(NVARCHAR(50), DATEADD(hour, @RowCounter2, '2025-08-03 19:29:00'), 120)
                WHEN c.ColumnName = 'ModifiedDate' THEN CONVERT(NVARCHAR(50), DATEADD(hour, @RowCounter2, '2025-08-03 19:29:00'), 120)
                WHEN c.ColumnName = 'CreatedBy' THEN CAST(@CreatedBy2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'Attachments' THEN 'attachment' + CAST(@CurrentListId2 AS NVARCHAR(10)) + '-' + CAST(@RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'Type' THEN 'Type' + CAST(@RowCounter2 AS NVARCHAR(10))
                WHEN c.ColumnName = 'ViewCount' THEN CAST(@RowCounter2 * 10 AS NVARCHAR(10))
                WHEN c.ColumnName = 'ChildCount' THEN CAST(@RowCounter2 * 5 AS NVARCHAR(10))
                WHEN c.ColumnName IN ('Labels', 'AssignedTo') THEN NULL
                WHEN c.ColumnName = 'IsRecord' THEN CAST(CASE WHEN @RowCounter2 % 2 = 0 THEN 1 ELSE 0 END AS NVARCHAR(1))
            END AS CellValue,
            @CreatedBy2 AS CreatedBy,
            '2025-08-04 10:28:00' AS CreatedAt,
            '2025-08-04 10:28:00' AS UpdatedAt
        FROM ListDynamicColumn c
        WHERE c.ListId = @CurrentListId2;

        SET @RowCounter2 = @RowCounter2 + 1;
    END;

    SET @CurrentListId2 = @CurrentListId2 + 1;
END;


INSERT INTO ListViewSettingValue (ListViewId, ViewTypeSettingKeyId, GroupByColumnId, RawValue, CreatedAt, UpdatedAt)
SELECT 
    lv.Id AS ListViewId,
    vtsk.Id AS ViewTypeSettingKeyId,
    CASE 
        WHEN vtsk.ViewSettingKeyId = 2 AND lv.ViewTypeId = 3 THEN (SELECT Id FROM ListDynamicColumn WHERE ListId = lv.ListId AND ColumnName = 'startdate')
        WHEN vtsk.ViewSettingKeyId = 3 AND lv.ViewTypeId = 3 THEN (SELECT Id FROM ListDynamicColumn WHERE ListId = lv.ListId AND ColumnName = 'endDate')
        WHEN vtsk.ViewSettingKeyId = 5 AND lv.ViewTypeId = 3 THEN (SELECT Id FROM ListDynamicColumn WHERE ListId = lv.ListId AND ColumnName = 'itemname')
        WHEN vtsk.ViewSettingKeyId = 7 AND lv.ViewTypeId = 2 THEN (SELECT Id FROM ListDynamicColumn WHERE ListId = lv.ListId AND ColumnName = 'itemchoice')
        ELSE NULL
    END AS GroupByColumnId,
    CASE 
        WHEN vtsk.ViewSettingKeyId = 1 THEN 'TRUE'
        ELSE NULL
    END AS RawValue,
    '2025-08-04 13:26:00' AS CreatedAt,
    '2025-08-04 13:26:00' AS UpdatedAt
FROM ListView lv
CROSS JOIN ViewTypeSettingKey vtsk
WHERE (lv.ViewTypeId = 1 AND vtsk.Id = 1)
   OR (lv.ViewTypeId = 2 AND vtsk.Id IN (2, 10))
   OR (lv.ViewTypeId = 3 AND vtsk.Id IN (3, 5, 6, 7, 8, 9))
   OR (lv.ViewTypeId = 4 AND vtsk.Id = 4)
   AND lv.Id BETWEEN 1 AND 240;


WITH RankedLists AS (
    SELECT 
        Id AS ListId,
        CreatedBy AS AccountId,
        ROW_NUMBER() OVER (PARTITION BY CreatedBy ORDER BY Id) AS ListRank
    FROM List
    WHERE ListStatus = 'Active'
)
INSERT INTO FavoriteList (ListId, AccountId, CreatedAt, UpdatedAt)
SELECT 
    ListId,
    AccountId,
    '2025-08-04 01:55:00',
    '2025-08-04 01:55:00'
FROM RankedLists
WHERE ListRank <= 2;


INSERT INTO FileAttachment (ListRowId, FileAttachmentName, FileUrl, CreatedAt, UpdatedAt)
SELECT 
    lr.Id AS ListRowId,
    'File 1 for Row ' + CAST(lr.Id AS NVARCHAR(10)) AS FileAttachmentName,
    'https://example.com/files/row' + CAST(lr.Id AS NVARCHAR(10)) + '/file1.pdf' AS FileUrl,
    '2025-08-04 02:02:00',
    '2025-08-04 02:02:00'
FROM ListRow lr
WHERE lr.ListRowStatus = 'Active'
UNION ALL
SELECT 
    lr.Id AS ListRowId,
    'File 2 for Row ' + CAST(lr.Id AS NVARCHAR(10)) AS FileAttachmentName,
    'https://example.com/files/row' + CAST(lr.Id AS NVARCHAR(10)) + '/file2.pdf' AS FileUrl,
    '2025-08-04 02:02:00',
    '2025-08-04 02:02:00'
FROM ListRow lr
WHERE lr.ListRowStatus = 'Active';


INSERT INTO ListRowComment (ListRowId, Content, CreatedBy, CreatedAt, UpdatedAt)
SELECT 
    lr.Id AS ListRowId,
    'Comment 1 for Row ' + CAST(lr.Id AS NVARCHAR(10)) + ': Great progress!' AS Content,
    lr.CreatedBy AS CreatedBy,
    '2025-08-04 02:09:00',
    '2025-08-04 02:09:00'
FROM ListRow lr
WHERE lr.ListRowStatus = 'Active'
UNION ALL
SELECT 
    lr.Id AS ListRowId,
    'Comment 2 for Row ' + CAST(lr.Id AS NVARCHAR(10)) + ': Needs review.' AS Content,
    lr.CreatedBy AS CreatedBy,
    '2025-08-04 02:09:00',
    '2025-08-04 02:09:00'
FROM ListRow lr
WHERE lr.ListRowStatus = 'Active';


INSERT INTO ObjectType (Code, DisplayName, Icon) VALUES
('LIST', 'List', 'list-icon.png'),
('LISTROW', 'List Row', 'row-icon.png'),
('FILE', 'File', 'file-icon.png');


UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 3;   -- User1, ListId=3
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 6;   -- User41, ListId=6
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 9;   -- User81, ListId=9
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 12;  -- User2, ListId=12
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 15;  -- User42, ListId=15
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 18;  -- User82, ListId=18
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 21;  -- User3, ListId=21
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 24;  -- User43, ListId=24
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 27;  -- User83, ListId=27
UPDATE List SET ListStatus = 'Inactive', UpdatedAt = GETDATE() WHERE Id = 30;  -- User4, ListId=30

INSERT INTO TrashItem (ObjectTypeId, ObjectId, UserDeleteId, DeletedAt, OriginalPath) VALUES
(1, 3, 1, GETDATE(), '/list/3'),   -- User1, ListId=3
(1, 6, 41, GETDATE(), '/list/6'),  -- User41, ListId=6
(1, 9, 81, GETDATE(), '/list/9'),  -- User81, ListId=9
(1, 12, 2, GETDATE(), '/list/12'), -- User2, ListId=12
(1, 15, 42, GETDATE(), '/list/15'),-- User42, ListId=15
(1, 18, 82, GETDATE(), '/list/18'),-- User82, ListId=18
(1, 21, 3, GETDATE(), '/list/21'), -- User3, ListId=21
(1, 24, 43, GETDATE(), '/list/24'),-- User43, ListId=24
(1, 27, 83, GETDATE(), '/list/27'),-- User83, ListId=27
(1, 30, 4, GETDATE(), '/list/30'); -- User4, ListId=30


INSERT INTO Scope (Code, DisplayName, ScopeDescription, Icon) VALUES
('PUBLIC', 'Public', 'Accessible to everyone', 'public-icon.png'),
('AUTHORIZED', 'Authorized', 'Accessible to authorized users', 'auth-icon.png'),
('SPECIFIC', 'Specific', 'Accessible to specific users', 'specific-icon.png');


INSERT INTO ShareLink (ListId, TargetUrl, ScopeId, PermissionId, LinkStatus, CreatedBy, CreatedAt, UpdatedAt)
SELECT 
    l.Id AS ListId,
    '/share/list/' + CAST(l.Id AS NVARCHAR(10)) + '/PUBLIC' AS TargetUrl,
    1 AS ScopeId, -- PUBLIC
    1 AS PermissionId, -- Admin
    'ACTIVE' AS LinkStatus,
    l.CreatedBy AS CreatedBy,
    GETDATE() AS CreatedAt,
    GETDATE() AS UpdatedAt
FROM List l
WHERE l.Id <= 60
UNION ALL
SELECT 
    l.Id AS ListId,
    '/share/list/' + CAST(l.Id AS NVARCHAR(10)) + '/AUTHORIZED' AS TargetUrl,
    2 AS ScopeId, -- AUTHORIZED
    2 AS PermissionId, -- Contributor
    'ACTIVE' AS LinkStatus,
    l.CreatedBy AS CreatedBy,
    GETDATE() AS CreatedAt,
    GETDATE() AS UpdatedAt
FROM List l
WHERE l.Id <= 60
UNION ALL
SELECT 
    l.Id AS ListId,
    '/share/list/' + CAST(l.Id AS NVARCHAR(10)) + '/SPECIFIC' AS TargetUrl,
    3 AS ScopeId, -- SPECIFIC
    3 AS PermissionId, -- Reader
    'ACTIVE' AS LinkStatus,
    l.CreatedBy AS CreatedBy,
    GETDATE() AS CreatedAt,
    GETDATE() AS UpdatedAt
FROM List l
WHERE l.Id <= 60;


INSERT INTO ShareLinkUserAccess (ShareLinkId, AccountId, Email, CreatedAt, UpdatedAt)
SELECT 
    sl.Id AS ShareLinkId,
    l.CreatedBy + 1 AS AccountId,
    a.Email AS Email,
    '2025-08-04 10:12:00',
    '2025-08-04 10:12:00'
FROM ShareLink sl
JOIN List l ON sl.ListId = l.Id
JOIN Account a ON a.Id = l.CreatedBy + 1
WHERE sl.Id <= 180
AND sl.Id NOT BETWEEN 61 AND 120
AND sl.ListId <= 60
AND (
    (sl.PermissionId = 1) -- PUBLIC
    OR (sl.PermissionId = 3) -- READER
)
UNION ALL
SELECT 
    sl.Id AS ShareLinkId,
    l.CreatedBy + 2 AS AccountId,
    a.Email AS Email,
    '2025-08-04 10:12:00',
    '2025-08-04 10:12:00'
FROM ShareLink sl
JOIN List l ON sl.ListId = l.Id
JOIN Account a ON a.Id = l.CreatedBy + 2
WHERE sl.Id <= 180
AND sl.Id NOT BETWEEN 61 AND 120
AND sl.ListId <= 60
AND (
    (sl.PermissionId = 1) -- PUBLIC
    OR (sl.PermissionId = 3) -- READER
)
UNION ALL
SELECT 
    sl.Id AS ShareLinkId,
    l.CreatedBy + 3 AS AccountId,
    a.Email AS Email,
    '2025-08-04 10:12:00',
    '2025-08-04 10:12:00'
FROM ShareLink sl
JOIN List l ON sl.ListId = l.Id
JOIN Account a ON a.Id = l.CreatedBy + 3
WHERE sl.Id <= 180
AND sl.Id NOT BETWEEN 61 AND 120 
AND sl.ListId <= 60
AND (
    (sl.PermissionId = 1) -- PUBLIC
    OR (sl.PermissionId = 3) -- READER
);


INSERT INTO ListMemberPermission (ListId, AccountId, HighestPermissionId, GrantedBy, Note, CreatedAt, UpdatedAt)
SELECT 
    sl.ListId,
    slua.AccountId,
    1 AS HighestPermissionId,
    l.CreatedBy AS GrantedBy,
    'Permission granted via public link access on ' + CAST(GETDATE() AS NVARCHAR(20)) AS Note,
    '2025-08-04 10:17:00',
    '2025-08-04 10:17:00'
FROM ShareLinkUserAccess slua
JOIN ShareLink sl ON slua.ShareLinkId = sl.Id
JOIN List l ON sl.ListId = l.Id
WHERE sl.ScopeId = 1
AND sl.Id BETWEEN 1 AND 60;


INSERT INTO ShareLinkSettingValue (ShareLinkId, KeySettingId, KeyValue)
SELECT 
    sl.Id AS ShareLinkId,
    24 AS KeySettingId, -- Expiration date
    '2026-08-20 00:00:00' AS KeyValue
FROM ShareLink sl
WHERE sl.Id % 2 = 1
AND sl.Id BETWEEN 1 AND 180
UNION ALL
SELECT 
    sl.Id AS ShareLinkId,
    26 AS KeySettingId, -- Is login required
    'TRUE' AS KeyValue
FROM ShareLink sl
WHERE sl.Id % 2 = 1
AND sl.Id BETWEEN 1 AND 180
UNION ALL
SELECT 
    sl.Id AS ShareLinkId,
    25 AS KeySettingId, -- Password
    'Pass' + CAST(sl.Id AS NVARCHAR(10)) AS KeyValue
FROM ShareLink sl
WHERE sl.Id % 2 = 0
AND sl.Id BETWEEN 1 AND 180
UNION ALL
SELECT 
    sl.Id AS ShareLinkId,
    26 AS KeySettingId, -- Is login required
    'FALSE' AS KeyValue
FROM ShareLink sl
WHERE sl.Id % 2 = 0
AND sl.Id BETWEEN 1 AND 180;

GO