USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[letterKeywordSetting]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[letterKeywordSetting](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[letter_key_words] [varchar](200) NULL,
	[key_desc] [varchar](200) NULL,
	[table_name] [varchar](max) NULL,
	[field_name] [varchar](100) NULL,
	[field_condition] [varchar](100) NULL,
	[letter_type] [varchar](1) NULL,
	[field_names] [varchar](max) NULL,
 CONSTRAINT [pk_idx_letterKeywordSetting_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
