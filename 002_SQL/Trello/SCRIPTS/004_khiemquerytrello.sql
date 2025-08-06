USE Trello ;
GO 
﻿
--1.Slide 4 | Home Page on the Boards tab → Recently viewed section, list all boards that the user has accessed recently 

SELECT 
        bo.Id board_id,
        bo.BoardName board_name, 
        bo.BackgroundUrl,
        uvh.AccessedAt
FROM UserViewHistories uvh
JOIN Boards bo ON bo.Id = uvh.OwnerId AND uvh.CategoryId = 2
WHERE uvh.UserId = 1
ORDER BY uvh.AccessedAt DESC;

--2.Slide 4 | Home Page on the Boards tab → Your Workspaces section, list all workspaces that the current user is a member of.
SELECT 
    wo.WorkspaceName, 
    wo.LogoUrl
FROM Workspaces wo
JOIN Members me ON me.OwnerId = wo.Id
WHERE me.CategoryId = 1 AND me.UserId = 1;

--3.Slide 4 | Home Page on the Boards tab → Workspace item → Boards button, list all boards  that the current user is a member of belonging to a specific workspace.
SELECT 
    bo.BoardName AS board_name, 
    bo.BackgroundUrl AS board_background,
    wo.WorkspaceName AS workspace_name
FROM Boards bo
JOIN Members me ON me.OwnerId = bo.Id
JOIN Workspaces wo ON wo.Id = bo.WorkspaceId
WHERE me.UserId = 1 AND me.CategoryId = 2; --2:Board

--4.Slide 4 | Home Page on the Header (top right corner), query boards have name that contains the keyword 'app'
SELECT 
    bo.Id board_id,
    bo.BoardName, 
    wo.WorkspaceName, 
    bo.BoardStatus
FROM Boards bo
JOIN Workspaces wo ON wo.Id = bo.Id
WHERE bo.BoardName LIKE '%app%';

--5.Slide 4 | Home Page on the Header (top right corner), show the total number of unread notifications of the user.
SELECT 
    COUNT(ac.UserId) AS number_of_notifications
FROM Notifications [no]
JOIN Activities ac ON ac.Id = no.ActivityId
WHERE ac.UserId = 1 AND no.IsRead = 0;

--6.Slide 5 | Home Page on the Templates tab → Main area, list all available public or user-created templates.
SELECT 
    te.Id template_id,
    us.PictureUrl AS user_picture, 
    us.Username AS author, 
    bo.BackgroundUrl AS board_background,
    te.Title AS template_title, 
    te.TemplateDescription AS tempalte_description, 
    te.Viewed, 
    te.Copied   
FROM Templates te
JOIN Users us ON us.Id = te.CreatedBy
JOIn Boards bo ON bo.Id = te.BoardId
ORDER BY Viewed DESC, Copied DESC;

--7.Slide 5 | Home Page on the Templates tab → Sidebar, list all template categories available for filtering.
SELECT 
    ct.Id category_type_id,
    ca.Id category_id,
    ca.CategoryName,
    ca.IsActive
FROM CategoryTypes ct
JOIN Categories ca ON ca.CategoryTypeId = ct.Id
WHERE ct.CategoryTypeValue = 'TemplateTypes'
ORDER BY ca.Position;

--8.Slide 5 | Home Page on the Templates tab, query templates have title that contains the keyword 'da' 
SELECT 
    bo.BackgroundUrl AS board_background, 
    us.Username AS created_by, 
    te.Title AS template_title
FROM Templates te
JOIN Users us ON us.Id = te.CreatedBy
JOIN Boards bo ON bo.Id = te.BoardId
WHERE Title LIKE '%da%';


--9. Slide 6 | Home Page on the Templates tab → Main area → Select specific tempalte, show information of a specific template.
WITH selected_template AS (
    SELECT
        Title,
        CreatedBy,
        Copied,
        Viewed,
        TemplateDescription,
        BoardId
    FROM Templates
    WHERE Id = 1
)

SELECT
    us.PictureUrl AS user_picture,
    st.TemplateDescription AS template_description,
    st.Title AS template_title,
    us.Username,
    st.Copied AS copied_number,
    st.Viewed AS viewed_number,
    st.BoardId
FROM selected_template st
JOIN Users us ON us.Id = st.CreatedBy;

--10.Slide 7 | Home Page on the Home tab → Checklist section, list all checklist items assigned to the user with status set to false (incomplete).
SELECT 
    cli.CheckListItemName AS checklist_item_name, 
    cli.CheckListItemStatus AS checklist_item_status,
    ca.Title AS card_title, 
    bo.BoardName AS board_name,
    us.PictureUrl
FROM CheckListItems cli
JOIN CheckLists cl ON cl.Id = cli.CheckListId
JOIN Cards ca ON ca.Id = cl.CardId
JOIN Stages st ON st.Id = ca.StageId
JOIN Boards bo ON bo.Id = st.BoardId
JOIN Members me ON me.Id = cli.MemberId
JOIN Users us ON us.Id = me.UserId
WHERE cli.CheckListItemStatus = 0 AND me.UserId = 1;

--11.Slide 7 Home Page on the Home tab → Assigned cards section, list all cards that are currently assigned to the user.
SELECT 
    bo.BoardName AS board_name,
    st.Title AS stage_title,
    ca.Title AS card_title,
    us.PictureUrl AS user_picture,
    ABS(DATEDIFF(DAY, GETDATE(), me.JoinedAt)) AS day_ago
FROM (Cards ca 
    JOIN Members me ON me.OwnerId = ca.Id 
                        AND me.UserId = 1 
                        AND me.CategoryId = 3)
JOIN Stages st ON st.Id = ca.StageId
JOIN Boards bo ON bo.Id = st.BoardId
JOIN Users us ON us.Id = me.UserId
ORDER BY day_ago;
--12.Slide 7 Home Page on the Home tab → Activity feed section, list all recent card's activities in the user's card.
SELECT 
    ca.Title AS card_title,
    wo.WorkspaceName AS workspace_name,
    bo.BoardName AS board_name,
    st.Title AS stage_title,
    us.Username AS username,
    us.PictureUrl AS user_picture,
    ABS(DATEDIFF(DAY, GETDATE(), ac.CreatedAt)) AS day_ago,
    ac.ActivityDescription AS activity_description
FROM (SELECT UserId, CategoryId, OwnerId, ActivityDescription, CreatedAt
    FROM Activities WHERE CategoryId = 3) ac
JOIN Cards ca ON ca.Id = ac.OwnerId
JOIN Stages st ON st.Id = ca.StageId
JOIN Boards bo ON bo.Id = st.BoardId
JOIN Workspaces wo ON wo.Id = bo.WorkspaceId
JOIN Users us ON us.Id = ac.UserId
Order By day_ago;
