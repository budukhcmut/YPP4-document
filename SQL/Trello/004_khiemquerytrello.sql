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
