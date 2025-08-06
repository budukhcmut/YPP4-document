﻿--1.Slide 4 | Home Page on the Boards tab → Recently viewed section, list all boards that the user has accessed recently.
SELECT 
        bo.Id board_id,
        bo.BoardName board_name, 
        bo.BackgroundUrl,
        bu.AccessedAt
FROM UserViewHistories bu
JOIN Boards bo ON bo.Id = bu.OwnerId AND bu.CategoryId = 2
WHERE bu.UserId = 1
ORDER BY bu.AccessedAt DESC;

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

--13.Slide 9 Home Page on the Workspace page → Boards section, list all boards under the selected workspace.
SELECT 
    bo.BackgroundUrl AS board_background,
    bo.BoardName AS board_name
FROM Boards bo
WHERE bo.WorkspaceId = 1;

--14.Slide 13 Home Page on the Workspace page → Members section, list all members in the workspace along with their permission on roles.
WITH BoardCountByEachUser AS(
    SELECT UserId, COUNT(UserId) AS board_count
    FROM Members
    WHERE CategoryId = 2
    GROUP BY UserId
)

SELECT 
    us.PictureUrl AS user_picture,
    us.Username,
    us.Email AS user_email,
    us.LastActive AS user_last_active,
    pe.PermissionName,
    bcb.board_count
FROM (
    SELECT 
        UserId, CategoryId, OwnerId,RolePermissonId 
    FROM Members
    WHERE CategoryId = 1 AND OwnerId = 1
    ) AS me
JOIN RolePermissions pe ON pe.Id = me.RolePermissonId
JOIN Users us ON us.Id = me.UserId
JOIN BoardCountByEachUser bcb ON bcb.UserId = me.UserId
ORDER BY OwnerId;

--15.Slide 13 Home Page on the Workspace page → Members section, count the total number of members in the selected workspace.
SELECT 
    COUNT(me.UserId) AS workspace_member_number
FROM Members me
JOIN RolePermissions pe ON pe.Id = me.RolePermissonId
WHERE me.CategoryId = 1 AND me.OwnerId = 153;

--16.Slide 14 Board Page on the Share Board pop-up, list all members in the board along with their permission on roles.
SELECT
    us.PictureUrl user_picture,
    us.Username,
    us.Email user_mail,
    pe.PermissionName
FROM (
    SELECT UserId, RolePermissonId, OwnerId
    FROM Members
    WHERE CategoryId = 2 AND OwnerId = 1
) AS me
JOIN RolePermissions pe ON pe.Id = me.RolePermissonId
JOIN Boards bo ON bo.Id = me.OwnerId
JOIN Users us ON us.Id = me.UserId;

--17.Slide 15 Board Page on the Share Board pop-up, list all permission options can choose
SELECT 
    PermissionName
FROM RolePermissions;


--18.Slide 17 Home Page on the Workspace page → Settings section, list all workspace setting keys with the current user's selected values.
SELECT 
    sk.KeyName, 
    COALESCE(sv.SettingValue, sk.DefaultValue) AS Value
FROM SettingKeys sk 
LEFT JOIN SettingValues sv ON sv.SettingKeyId = sk.Id AND sk.CategoryId = 4 AND sv.OwnerId = 1;

--19.Slide 17 Home Page on the Workspace page → Settings section, list all settingoption of a specific workspace setting.
WITH sk AS (
    SELECT 
    KeyName,
    SettingKeyDescription,
    Id
    FROM SettingKeys
    WHERE CategoryId = 1 --workspace
)

SELECT 
    sk.KeyName AS setting_key,
    sk.SettingKeyDescription,
    so.DisplayValue AS setting_option_display_value
FROM SettingKeySettingOptions sso 
JOIN sk ON sso.SettingKeyId = sk.Id
JOIN SettingOptions so ON so.Id = sso.SettingOptionId;


--20.Slide 19 Board Page on the Setting pop-up, list all board's setting key and user's choice of a specific user
SELECT 
    sk.KeyName, 
    COALESCE(sv.SettingValue, sk.DefaultValue) as setting_value
FROM (
    SELECT
        Id,
        KeyName,
        DefaultValue
    FROM SettingKeys
    WHERE CategoryId = 2
) AS sk
LEFT JOIN SettingValues sv ON sv.SettingKeyId = sk.Id AND sv.OwnerId = 1;

--21.Slide 21 Home Page on the Workspace page → Power-Ups section, list on power-ups of a specific workspace are using
WITH boards_in_specific_workspace AS (
    SELECT 
        Id, 
        WorkspaceId
    FROM Boards
    WHERE WorkspaceId = 1
), 
power_ups_in_workspace AS (
    SELECT
        bop.PowerUpId AS power_ups_id,
        COUNT(bop.PowerUpId) AS number_of_boards

    FROM boards_in_specific_workspace bo
    JOIN BoardPowerUps bop ON bop.BoardId = bo.Id
    GROUP BY bop.PowerUpId
)

SELECT 
    pu.IconUrl AS power_up_icon,
    pu.PowerUpName AS power_up_name,
    puiw.number_of_boards
FROM power_ups_in_workspace puiw
JOIN PowerUps pu ON pu.Id = puiw.power_ups_id;

--22.Slide 22 Home Page on the Workspace page → Power-Ups section → click a specific power-ups, show information of a specific power-up
WITH board_using_powerup_count AS (
    SELECT
        PowerUpId,
        COUNT(PowerUpId) AS number_of_board
    FROM BoardPowerUps
    WHERE PowerUpId = 1
    GROUP BY PowerUpId
)

SELECT
    po.Id,
    po.IconUrl,
    po.AuthorName,
    po.CategoryId, --PowerUpCategoryId
    po.EmailContact,
    po.PolicyUrl,
    po.PowerUpName,
    po.PowerUpDescription,
    bc.number_of_board
FROM PowerUps po
JOIN board_using_powerup_count bc ON bc.PowerUpId = po.Id;

--23.Slide 24 Home Page on the Workspace page → Upgrade section, list all available billing plans that the workspace can upgrade to.
SELECT 
    PlanName AS billing_plan_name,
    --PlanDescription AS billing_plan_description,
    PricePerUser
FROM BillingPlans;

--24.Slide 26.Home Page on the Workspace page → Billing section, show information of payment and billing
WITH billing_selected_workspace AS (
    SELECT
        Id,
        WorkspaceId,
        BillingContactName,
        BillingContactEmail,
        AdditionalInvoiceDetail
    FROM BillingContacts
    WHERE WorkspaceId = 1
),
member_in_workspace AS (
    SELECT
        OwnerId,
        COUNT(OwnerId) AS number_of_member
    FROM Members
    WHERE CategoryId = 1 AND OwnerId = 1
    GROUP BY OwnerId
)

SELECT 
    su.EndDate AS end_day_subscription,
    bp.PlanName AS plan_name,
    bp.PricePerUser AS plan_price_per_person,
    miw.number_of_member,
    su.IsMonthly AS is_monthly,
    pai.CardNumber AS credit_card_number,
    bsw.BillingContactName AS billing_contact_name,
    bsw.BillingContactEmail AS billing_contact_email,
    bsw.AdditionalInvoiceDetail AS invoice_details

FROM billing_selected_workspace bsw
JOIN PaymentInformations pai ON pai.BillingContactId = bsw.Id
JOIN Subscriptions su ON su.BillingContactId = bsw.Id
JOIN BillingPlans bp ON bp.Id = su.BillingPlanId
JOIN member_in_workspace miw ON miw.OwnerId = bsw.WorkspaceId;

--25.Slide 30. Home Page on the Workspace page → Export section, list all history exports of a selected workspace
SELECT
    CreatedAt,
    Size
FROM Exports
WHERE WorkspaceId = 1;

--26. Slide 33. Select a board → Board page, list all Stage in a selected board include Card
SELECT
    ca.Title AS card_title,
    ca.Position AS card_postion,
    st.Title AS stage_title,
    bo.BoardName AS board_name,
    bo.BoardStatus AS board_status
FROM (
    SELECT
        Id,
        BoardName,
        BoardStatus,
        WorkspaceId
    FROM Boards
    WHERE Id = 1
) bo
JOIN Stages st ON st.BoardId = bo.Id
JOIN Cards ca ON ca.StageId = st.Id
ORDER BY st.Position, ca.Position;

--27. Slide 34. Select a board → Board page → in a stage, show information of a stage
WITH card_in_specific_stage AS (
    SELECT 
        Id AS card_id,
        Title AS card_title,
        CardLocation AS card_location,
        StartDate AS card_start_date,
        DueDate AS card_due_date,
        CategoryId, --CoverType
        CoverValue,
        Position AS card_position,
        CardStatus,
        StageId
    FROM Cards
    WHERE StageId = 1
),
attachment_count_by_card AS (
    SELECT
        CardId, 
        COUNT(CardId) AS number_of_attachment
    FROM Attachments
    WHERE CardId in (SELECT card_id FROM card_in_specific_stage)
    GROUP BY CardId
),
checklist_item_count AS (
    SELECT 
        cl.CardId,
        COUNT(CardId) AS number_of_checklist_item
    FROM CheckLists cl
    JOIN CheckListItems cli ON cli.CheckListId = cl.Id
    WHERE CardId in (
        SELECT
            card_id
        FROM card_in_specific_stage
    )
    GROUP BY CardId
)

SELECT 
     ca.card_id,
     ca.card_title,
     ca.card_location,
     ca.card_start_date,
     ca.card_due_date,
     ca.CategoryId,
     ca.CoverValue,
     card_position,
     ca.CardStatus,
     ca.StageId,
    at.number_of_attachment,
    ch.number_of_checklist_item
FROM card_in_specific_stage ca
JOIN attachment_count_by_card at ON at.CardId = ca.card_id
JOIN checklist_item_count ch ON ch.CardId = ca.card_id

--28 Slide 34. Select a board → Board page → in a stage, show picture of each user is member of specific card
SELECT
    me.card_id,
    us.PictureUrl AS user_picture
FROM (
    SELECT 
        UserId,
        OwnerId AS card_id
    FROM Members me
    JOIN Categories ct ON ct.Id = me.CategoryId
    WHERE ct.CategoryName = 'CARD' AND me.OwnerId = 1 --OwnerId is CardId
) me
JOIN Users us ON us.Id = me.UserId;

--29. Slide 35. Select a board → Board page → in a stage → select a card, show labels of a card
SELECT
    ca.Id AS card_id,
    ca.Title AS card_title,
    la.Id AS [label_id],
    co.ColorName AS color_name,
    co.Icon AS color_icon
FROM (
    SELECT 
        CardId,
        LabelId
    FROM CardLabels
    WHERE CardId = 1
) cl
JOIN Cards ca ON ca.Id = cl.CardId
JOIN Labels la ON la.Id = cl.LabelId
JOIN Colors co ON co.Id = la.ColorId;

--30. Slide 36. Select a board → Board page → in a stage → select a card, show activities in a specific card
SELECT 
    us.PictureUrl AS user_picture,
    us.Username,
    ac.ActivityDescription,
    ac.CreatedAt,
    card_id
FROM (
    SELECT 
        UserId,
        OwnerId AS card_id,
        ActivityDescription,
        CreatedAt
    FROM
        Activities
    WHERE CategoryId = 3 AND OwnerId = 1 --3:Card
) ac
JOIN Users us ON us.Id = ac.UserId
ORDER BY CreatedAt DESC;

--31. Slide 37. Select a board → Board page → in a stage → select a card → click on cover, show list of colors with icon can selected
SELECT 
    Id,
    ColorName,
    Icon
FROM Colors;

--32. Slide 38. Select a board → Board page → in a stage → select a card, show list of labels with color that card selected
SELECT
    cl.CardId,
    cl.LabelId,
    la.Title AS label_title,
    co.ColorName AS color_name,
    co.Icon AS color_icon
FROM (
    SELECT
        CardId,
        LabelId
    FROM
        CardLabels
    WHERE CardId = 1
) cl
JOIN Labels la ON la.Id = cl.LabelId
JOIN Colors co ON co.Id = la.ColorId;

--33. Slide 40. Select a board → Board page → in a stage → select a card → checklist section, checklist and its item in a specific card(832)
SELECT
    cl.CardId AS card_id,
    cl.CheckListName AS checklist_name,
    --cl.checklist_position,
    cli.CheckListItemStatus AS checklist_item_status,
    cli.CheckListItemName AS checklist_item_name,
    cli.DueDate AS checklist_item_due_date,
    --cli.Position AS checklist_item_position,
    us.PictureUrl AS user_picture
FROM (
    SELECT 
        Id,
        CheckListName,
        CardId
        --,Position AS checklist_position
    FROM CheckLists
    WHERE CardId = 832
) cl
JOIN CheckListItems cli ON cli.CheckListId = cl.Id
JOIN Members me ON me.Id = cli.MemberId
JOIN Users us ON us.Id = me.UserId;
--ORDER BY cl.checklist_position, cli.Position;
--34. Slide 40. Select a board → Board page → in a stage → select a card → checklist section, 
--              list members in card, 
--                              board contains this card, 
--                              workspace contains this board to assign in checklist's item
WITH RankedUsers AS (
    SELECT
        us.Id AS [user_id],
        us.PictureUrl AS user_picture, 
        us.Username,
        me.CategoryId,
        ROW_NUMBER() OVER (PARTITION BY us.Id ORDER BY me.CategoryId DESC) AS rn
    FROM (
        SELECT
            Id,
            StageId
        FROM Cards
        WHERE Id = 832
    ) ca
    JOIN Stages st ON st.Id = ca.StageId
    JOIN Boards bo ON bo.Id = st.BoardId
    JOIN Workspaces wo ON wo.Id = bo.WorkspaceId
    RIGHT JOIN Members me ON  (me.CategoryId = 1 AND me.OwnerId = wo.Id) OR
                        (me.CategoryId = 2 AND me.OwnerId = bo.Id) OR
                        (me.CategoryId = 3 AND me.OwnerId = ca.Id)
    JOIN Users us ON us.Id = me.UserId
)

SELECT 
    [user_id],
    user_picture,
    Username,
    CategoryId
FROM RankedUsers
WHERE rn = 1
ORDER BY CategoryId DESC;

--35. Slide 42. Select a board → Board page → in a stage → select a card → attachment section, show all attachment have LINK type in a specific card 
SELECT 
    AttachmentPath AS [attachment_path],
    AttachmentName AS attachment_name,
    CreatedAt,
    CategoryId,
    IsCover,
    CardId
FROM Attachments
WHERE CategoryId = 60 AND CardId = 2
ORDER BY CreatedAt DESC;
--36. Slide 42. Select a board → Board page → in a stage → select a card → attachment section, show all attachment have FILE type in a specific card 
SELECT 
    AttachmentPath AS [attachment_path],
    AttachmentName AS attachment_name,
    CreatedAt,
    CategoryId,
    IsCover,
    CardId
FROM Attachments
WHERE CategoryId = 61 AND CardId = 2

--37. Slide 43. Select a board → Board page → in a stage → select a card → comment section, show all comment in a specific card(2) 
SELECT
    co.Id AS comment_id,
    us.PictureUrl AS user_picture,
    us.Username,
    co.CreatedAt,
    co.Content,
    co.CardId
FROM (
    SELECT 
        Id,
        Content,
        CreatedAt,
        CreatedBy,
        CardId
    FROM Comments
    WHERE CardId = 2
) co
JOIN Users us ON us.Id = co.CreatedBy

--38. Slide 43. Select a board → Board page → in a stage → select a card → comment section, show all reactions in a comment(1) of a specific card 
SELECT
    re.Id AS reaction_id,
    re.icon,
    COUNT(re.Id) AS number_of_reaction
FROM (
    SELECT
        CommentId,
        ReactionId
    FROM CommentReactions
    WHERE CommentId = 1
) cr
JOIN Reactions re ON re.Id = cr.ReactionId
GROUP BY re.Id, re.icon;

--39. Slide 43. Select a board → Board page → in a stage → select a card → comment section → show detail, 
--          show all activities of a specific card
SELECT 
    us.PictureUrl AS user_picture,
    us.Username,
    ac.ActivityDescription AS activity_description,
    ac.CreatedAt AS activity_created_at
FROM (
    SELECT
        Id,
        ActivityDescription,
        CreatedAt,
        UserId,
        OwnerId AS card_id
    FROM Activities
    WHERE CategoryId = 3 AND OwnerId = 1
) ac
JOIN Users us ON us.Id = ac.UserId;

--40. Slide 45. Select a board → Board page → in a stage → select a card → CustomField section, 
--          show all CustomField and Selection of a specific card
WITH CustomFieldOfCard AS (
    SELECT 
        Id,
        Title,
        CategoryId, --DataTypeId
        Position,
        BoardId
    FROM CustomFields cf
    WHERE BoardId = (
        SELECT 
            st.BoardId
        FROM (
            SELECT 
                Id,
                StageId
            FROM Cards
            WHERE Id = 7
        ) ca
        JOIN Stages st ON st.Id = ca.StageId
    )
)
SELECT
    cfoc.Id AS custom_field_id,
    cfoc.Title AS custom_field_title,
    cfoc.CategoryId AS custom_field_type,
    cfoc.Position AS custom_field_position,
    fv.FieldValue AS field_value,
    CASE 
        WHEN cfoc.CategoryId = 1 THEN fi.FieldItemValue
        ELSE fv.FieldValue 
    END AS field_item_value,
    fv.CardId AS card_id
FROM CustomFieldOfCard cfoc
JOIN FieldValues fv ON fv.CustomFieldId = cfoc.Id AND fv.CardId = 7
LEFT JOIN FieldItems fi ON cfoc.CategoryId = 7 AND fi.Id = TRY_CAST(fv.FieldValue AS INT);

--41. Slide 45. Select a board → Board page → in a stage → select a card → CustomField section, 
--          show all options of a custom field with DROPDOWN type with Id = 21

SELECT 
    cf.Id AS custom_field_id,
    cf.Title AS custom_field_title,
    cf.CategoryId AS custom_field_type, --DataTypeId
    fi.FieldItemValue AS field_item_value,
    fi.Position AS field_item_position,
    co.ColorName AS color_name,
    co.Icon AS color_icon
FROM CustomFields cf
JOIN FieldItems fi ON fi.CustomFieldId = cf.Id
JOIN Colors co ON co.Id = fi.ColorId
WHERE cf.Id = 21
ORDER BY cf.Id, fi.Position;

--42. Slide 47. Select a board → Board page → Setting section → Click stickers, show list of sticker can select
SELECT 
    Id,
    StickerName,
    StickerUrl
FROM Stickers;

--43. Slide 47. Select a board → Board page → in a stage, show sticker in cover of a card
SELECT 
    st.Id AS sticker_id,
    st.StickerName AS sticker_name,
    st.StickerUrl AS sticker_url,
    PositionX,
    PositionY,
    IndexZ,
    CardId AS card_id
FROM CardStickers cs
JOIN Stickers st ON st.Id = cs.StickerId
WHERE CardId = 1;

--44. Slide 49. Click notification icon, show all notification are unread
SELECT 
    noti.Id AS notification_id,
    us.PictureUrl AS user_picture,
    us.Username,
    ac.ActivityDescription AS activity_description,
    ac.CategoryId,
    ac.OwnerId
FROM Notifications noti
JOIN Activities ac ON ac.Id = noti.ActivityId
JOIN Users us ON us.Id = ac.UserId
WHERE ac.UserId = 2 AND noti.IsRead = 0; --0 means UNREAD

--45. Slide 49. Click notification icon, show all notification are read
SELECT 
    noti.Id AS notification_id,
    us.PictureUrl AS user_picture,
    us.Username,
    ac.ActivityDescription AS activity_description,
    ac.CategoryId,
    ac.OwnerId
FROM Notifications noti
JOIN Activities ac ON ac.Id = noti.ActivityId
JOIN Users us ON us.Id = ac.UserId
WHERE ac.UserId = 2 AND noti.IsRead = 1 --1 means already READ
ORDER BY ac.CategoryId;

--46. Slide 52. Click setting of a workspace → click board tab, show board and collection its belong with
SELECT 
    bo.BoardName AS board_name,
    co.CollectionName AS collection_name
FROM BoardCollections bc
JOIN Boards bo ON bo.Id = bc.BoardId
JOIN Collections co ON co.Id = bc.CollectionId
WHERE bo.WorkspaceId = 1
ORDER BY board_name;

select 
    bo.Id board_id,
    bo.BoardName board_name,
    bo.WorkspaceId workspace_id,
    co.Id collection_id,
    co.CollectionName
from Boards bo
JOIN BoardCollections bc ON bc.BoardId = bo.Id 
JOIN Collections co ON co.Id = bc.CollectionId
WHERE bo.WorkspaceId = 1 AND co.WorkspaceId = 1
select * from boards where WorkspaceId = 1
select * from Collections where WorkspaceId = 1